/*
 * Copyright (C) 2016 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <string>

#include <android-base/file.h>
#include <android-base/properties.h>
#include <android-base/stringprintf.h>
#include <android-base/strings.h>
#include <android-base/test_utils.h>
#include <bootloader_message/bootloader_message.h>
#include <gtest/gtest.h>
#include <ziparchive/zip_archive.h>

#include "common/test_constants.h"
#include "edify/expr.h"
#include "error_code.h"
#include "updater/install.h"
#include "updater/updater.h"

struct selabel_handle *sehandle = nullptr;

static void expect(const char* expected, const char* expr_str, CauseCode cause_code,
                   UpdaterInfo* info = nullptr) {
  Expr* e;
  int error_count = 0;
  ASSERT_EQ(0, parse_string(expr_str, &e, &error_count));
  ASSERT_EQ(0, error_count);

  State state(expr_str, info);

  std::string result;
  bool status = Evaluate(&state, e, &result);

  if (expected == nullptr) {
    ASSERT_FALSE(status);
  } else {
    ASSERT_TRUE(status);
    ASSERT_STREQ(expected, result.c_str());
  }

  // Error code is set in updater/updater.cpp only, by parsing State.errmsg.
  ASSERT_EQ(kNoError, state.error_code);

  // Cause code should always be available.
  ASSERT_EQ(cause_code, state.cause_code);
}

class UpdaterTest : public ::testing::Test {
  protected:
    virtual void SetUp() {
        RegisterBuiltins();
        RegisterInstallFunctions();
    }
};

TEST_F(UpdaterTest, getprop) {
    expect(android::base::GetProperty("ro.product.device", "").c_str(),
           "getprop(\"ro.product.device\")",
           kNoCause);

    expect(android::base::GetProperty("ro.build.fingerprint", "").c_str(),
           "getprop(\"ro.build.fingerprint\")",
           kNoCause);

    // getprop() accepts only one parameter.
    expect(nullptr, "getprop()", kArgsParsingFailure);
    expect(nullptr, "getprop(\"arg1\", \"arg2\")", kArgsParsingFailure);
}

TEST_F(UpdaterTest, sha1_check) {
    // sha1_check(data) returns the SHA-1 of the data.
    expect("81fe8bfe87576c3ecb22426f8e57847382917acf", "sha1_check(\"abcd\")", kNoCause);
    expect("da39a3ee5e6b4b0d3255bfef95601890afd80709", "sha1_check(\"\")", kNoCause);

    // sha1_check(data, sha1_hex, [sha1_hex, ...]) returns the matched SHA-1.
    expect("81fe8bfe87576c3ecb22426f8e57847382917acf",
           "sha1_check(\"abcd\", \"81fe8bfe87576c3ecb22426f8e57847382917acf\")",
           kNoCause);

    expect("81fe8bfe87576c3ecb22426f8e57847382917acf",
           "sha1_check(\"abcd\", \"wrong_sha1\", \"81fe8bfe87576c3ecb22426f8e57847382917acf\")",
           kNoCause);

    // Or "" if there's no match.
    expect("",
           "sha1_check(\"abcd\", \"wrong_sha1\")",
           kNoCause);

    expect("",
           "sha1_check(\"abcd\", \"wrong_sha1\", \"wrong_sha2\")",
           kNoCause);

    // sha1_check() expects at least one argument.
    expect(nullptr, "sha1_check()", kArgsParsingFailure);
}

TEST_F(UpdaterTest, file_getprop) {
    // file_getprop() expects two arguments.
    expect(nullptr, "file_getprop()", kArgsParsingFailure);
    expect(nullptr, "file_getprop(\"arg1\")", kArgsParsingFailure);
    expect(nullptr, "file_getprop(\"arg1\", \"arg2\", \"arg3\")", kArgsParsingFailure);

    // File doesn't exist.
    expect(nullptr, "file_getprop(\"/doesntexist\", \"key1\")", kFileGetPropFailure);

    // Reject too large files (current limit = 65536).
    TemporaryFile temp_file1;
    std::string buffer(65540, '\0');
    ASSERT_TRUE(android::base::WriteStringToFile(buffer, temp_file1.path));

    // Read some keys.
    TemporaryFile temp_file2;
    std::string content("ro.product.name=tardis\n"
                        "# comment\n\n\n"
                        "ro.product.model\n"
                        "ro.product.board =  magic \n");
    ASSERT_TRUE(android::base::WriteStringToFile(content, temp_file2.path));

    std::string script1("file_getprop(\"" + std::string(temp_file2.path) +
                       "\", \"ro.product.name\")");
    expect("tardis", script1.c_str(), kNoCause);

    std::string script2("file_getprop(\"" + std::string(temp_file2.path) +
                       "\", \"ro.product.board\")");
    expect("magic", script2.c_str(), kNoCause);

    // No match.
    std::string script3("file_getprop(\"" + std::string(temp_file2.path) +
                       "\", \"ro.product.wrong\")");
    expect("", script3.c_str(), kNoCause);

    std::string script4("file_getprop(\"" + std::string(temp_file2.path) +
                       "\", \"ro.product.name=\")");
    expect("", script4.c_str(), kNoCause);

    std::string script5("file_getprop(\"" + std::string(temp_file2.path) +
                       "\", \"ro.product.nam\")");
    expect("", script5.c_str(), kNoCause);

    std::string script6("file_getprop(\"" + std::string(temp_file2.path) +
                       "\", \"ro.product.model\")");
    expect("", script6.c_str(), kNoCause);
}

TEST_F(UpdaterTest, package_extract_dir) {
  // package_extract_dir expects 2 arguments.
  expect(nullptr, "package_extract_dir()", kArgsParsingFailure);
  expect(nullptr, "package_extract_dir(\"arg1\")", kArgsParsingFailure);
  expect(nullptr, "package_extract_dir(\"arg1\", \"arg2\", \"arg3\")", kArgsParsingFailure);

  std::string zip_path = from_testdata_base("ziptest_valid.zip");
  ZipArchiveHandle handle;
  ASSERT_EQ(0, OpenArchive(zip_path.c_str(), &handle));

  // Need to set up the ziphandle.
  UpdaterInfo updater_info;
  updater_info.package_zip = handle;

  // Extract "b/c.txt" and "b/d.txt" with package_extract_dir("b", "<dir>").
  TemporaryDir td;
  std::string temp_dir(td.path);
  std::string script("package_extract_dir(\"b\", \"" + temp_dir + "\")");
  expect("t", script.c_str(), kNoCause, &updater_info);

  // Verify.
  std::string data;
  std::string file_c = temp_dir + "/c.txt";
  ASSERT_TRUE(android::base::ReadFileToString(file_c, &data));
  ASSERT_EQ(kCTxtContents, data);

  std::string file_d = temp_dir + "/d.txt";
  ASSERT_TRUE(android::base::ReadFileToString(file_d, &data));
  ASSERT_EQ(kDTxtContents, data);

  // Modify the contents in order to retry. It's expected to be overwritten.
  ASSERT_TRUE(android::base::WriteStringToFile("random", file_c));
  ASSERT_TRUE(android::base::WriteStringToFile("random", file_d));

  // Extract again and verify.
  expect("t", script.c_str(), kNoCause, &updater_info);

  ASSERT_TRUE(android::base::ReadFileToString(file_c, &data));
  ASSERT_EQ(kCTxtContents, data);
  ASSERT_TRUE(android::base::ReadFileToString(file_d, &data));
  ASSERT_EQ(kDTxtContents, data);

  // Clean up the temp files under td.
  ASSERT_EQ(0, unlink(file_c.c_str()));
  ASSERT_EQ(0, unlink(file_d.c_str()));

  // Extracting "b/" (with slash) should give the same result.
  script = "package_extract_dir(\"b/\", \"" + temp_dir + "\")";
  expect("t", script.c_str(), kNoCause, &updater_info);

  ASSERT_TRUE(android::base::ReadFileToString(file_c, &data));
  ASSERT_EQ(kCTxtContents, data);
  ASSERT_TRUE(android::base::ReadFileToString(file_d, &data));
  ASSERT_EQ(kDTxtContents, data);

  ASSERT_EQ(0, unlink(file_c.c_str()));
  ASSERT_EQ(0, unlink(file_d.c_str()));

  // Extracting "" is allowed. The entries will carry the path name.
  script = "package_extract_dir(\"\", \"" + temp_dir + "\")";
  expect("t", script.c_str(), kNoCause, &updater_info);

  std::string file_a = temp_dir + "/a.txt";
  ASSERT_TRUE(android::base::ReadFileToString(file_a, &data));
  ASSERT_EQ(kATxtContents, data);
  std::string file_b = temp_dir + "/b.txt";
  ASSERT_TRUE(android::base::ReadFileToString(file_b, &data));
  ASSERT_EQ(kBTxtContents, data);
  std::string file_b_c = temp_dir + "/b/c.txt";
  ASSERT_TRUE(android::base::ReadFileToString(file_b_c, &data));
  ASSERT_EQ(kCTxtContents, data);
  std::string file_b_d = temp_dir + "/b/d.txt";
  ASSERT_TRUE(android::base::ReadFileToString(file_b_d, &data));
  ASSERT_EQ(kDTxtContents, data);

  ASSERT_EQ(0, unlink(file_a.c_str()));
  ASSERT_EQ(0, unlink(file_b.c_str()));
  ASSERT_EQ(0, unlink(file_b_c.c_str()));
  ASSERT_EQ(0, unlink(file_b_d.c_str()));
  ASSERT_EQ(0, rmdir((temp_dir + "/b").c_str()));

  // Extracting non-existent entry should still give "t".
  script = "package_extract_dir(\"doesntexist\", \"" + temp_dir + "\")";
  expect("t", script.c_str(), kNoCause, &updater_info);

  // Only relative zip_path is allowed.
  script = "package_extract_dir(\"/b\", \"" + temp_dir + "\")";
  expect("", script.c_str(), kNoCause, &updater_info);

  // Only absolute dest_path is allowed.
  script = "package_extract_dir(\"b\", \"path\")";
  expect("", script.c_str(), kNoCause, &updater_info);

  CloseArchive(handle);
}

// TODO: Test extracting to block device.
TEST_F(UpdaterTest, package_extract_file) {
  // package_extract_file expects 1 or 2 arguments.
  expect(nullptr, "package_extract_file()", kArgsParsingFailure);
  expect(nullptr, "package_extract_file(\"arg1\", \"arg2\", \"arg3\")", kArgsParsingFailure);

  std::string zip_path = from_testdata_base("ziptest_valid.zip");
  ZipArchiveHandle handle;
  ASSERT_EQ(0, OpenArchive(zip_path.c_str(), &handle));

  // Need to set up the ziphandle.
  UpdaterInfo updater_info;
  updater_info.package_zip = handle;

  // Two-argument version.
  TemporaryFile temp_file1;
  std::string script("package_extract_file(\"a.txt\", \"" + std::string(temp_file1.path) + "\")");
  expect("t", script.c_str(), kNoCause, &updater_info);

  // Verify the extracted entry.
  std::string data;
  ASSERT_TRUE(android::base::ReadFileToString(temp_file1.path, &data));
  ASSERT_EQ(kATxtContents, data);

  // Now extract another entry to the same location, which should overwrite.
  script = "package_extract_file(\"b.txt\", \"" + std::string(temp_file1.path) + "\")";
  expect("t", script.c_str(), kNoCause, &updater_info);

  ASSERT_TRUE(android::base::ReadFileToString(temp_file1.path, &data));
  ASSERT_EQ(kBTxtContents, data);

  // Missing zip entry. The two-argument version doesn't abort.
  script = "package_extract_file(\"doesntexist\", \"" + std::string(temp_file1.path) + "\")";
  expect("", script.c_str(), kNoCause, &updater_info);

  // Extract to /dev/full should fail.
  script = "package_extract_file(\"a.txt\", \"/dev/full\")";
  expect("", script.c_str(), kNoCause, &updater_info);

  // One-argument version.
  script = "sha1_check(package_extract_file(\"a.txt\"))";
  expect(kATxtSha1Sum.c_str(), script.c_str(), kNoCause, &updater_info);

  script = "sha1_check(package_extract_file(\"b.txt\"))";
  expect(kBTxtSha1Sum.c_str(), script.c_str(), kNoCause, &updater_info);

  // Missing entry. The one-argument version aborts the evaluation.
  script = "package_extract_file(\"doesntexist\")";
  expect(nullptr, script.c_str(), kPackageExtractFileFailure, &updater_info);

  CloseArchive(handle);
}

TEST_F(UpdaterTest, write_value) {
  // write_value() expects two arguments.
  expect(nullptr, "write_value()", kArgsParsingFailure);
  expect(nullptr, "write_value(\"arg1\")", kArgsParsingFailure);
  expect(nullptr, "write_value(\"arg1\", \"arg2\", \"arg3\")", kArgsParsingFailure);

  // filename cannot be empty.
  expect(nullptr, "write_value(\"value\", \"\")", kArgsParsingFailure);

  // Write some value to file.
  TemporaryFile temp_file;
  std::string value = "magicvalue";
  std::string script("write_value(\"" + value + "\", \"" + std::string(temp_file.path) + "\")");
  expect("t", script.c_str(), kNoCause);

  // Verify the content.
  std::string content;
  ASSERT_TRUE(android::base::ReadFileToString(temp_file.path, &content));
  ASSERT_EQ(value, content);

  // Allow writing empty string.
  script = "write_value(\"\", \"" + std::string(temp_file.path) + "\")";
  expect("t", script.c_str(), kNoCause);

  // Verify the content.
  ASSERT_TRUE(android::base::ReadFileToString(temp_file.path, &content));
  ASSERT_EQ("", content);

  // It should fail gracefully when write fails.
  script = "write_value(\"value\", \"/proc/0/file1\")";
  expect("", script.c_str(), kNoCause);
}

TEST_F(UpdaterTest, get_stage) {
  // get_stage() expects one argument.
  expect(nullptr, "get_stage()", kArgsParsingFailure);
  expect(nullptr, "get_stage(\"arg1\", \"arg2\")", kArgsParsingFailure);
  expect(nullptr, "get_stage(\"arg1\", \"arg2\", \"arg3\")", kArgsParsingFailure);

  // Set up a local file as BCB.
  TemporaryFile tf;
  std::string temp_file(tf.path);
  bootloader_message boot;
  strlcpy(boot.stage, "2/3", sizeof(boot.stage));
  std::string err;
  ASSERT_TRUE(write_bootloader_message_to(boot, temp_file, &err));

  // Can read the stage value.
  std::string script("get_stage(\"" + temp_file + "\")");
  expect("2/3", script.c_str(), kNoCause);

  // Bad BCB path.
  script = "get_stage(\"doesntexist\")";
  expect("", script.c_str(), kNoCause);
}

TEST_F(UpdaterTest, set_stage) {
  // set_stage() expects two arguments.
  expect(nullptr, "set_stage()", kArgsParsingFailure);
  expect(nullptr, "set_stage(\"arg1\")", kArgsParsingFailure);
  expect(nullptr, "set_stage(\"arg1\", \"arg2\", \"arg3\")", kArgsParsingFailure);

  // Set up a local file as BCB.
  TemporaryFile tf;
  std::string temp_file(tf.path);
  bootloader_message boot;
  strlcpy(boot.command, "command", sizeof(boot.command));
  strlcpy(boot.stage, "2/3", sizeof(boot.stage));
  std::string err;
  ASSERT_TRUE(write_bootloader_message_to(boot, temp_file, &err));

  // Write with set_stage().
  std::string script("set_stage(\"" + temp_file + "\", \"1/3\")");
  expect(tf.path, script.c_str(), kNoCause);

  // Verify.
  bootloader_message boot_verify;
  ASSERT_TRUE(read_bootloader_message_from(&boot_verify, temp_file, &err));

  // Stage should be updated, with command part untouched.
  ASSERT_STREQ("1/3", boot_verify.stage);
  ASSERT_STREQ(boot.command, boot_verify.command);

  // Bad BCB path.
  script = "set_stage(\"doesntexist\", \"1/3\")";
  expect("", script.c_str(), kNoCause);

  script = "set_stage(\"/dev/full\", \"1/3\")";
  expect("", script.c_str(), kNoCause);
}

TEST_F(UpdaterTest, set_progress) {
  // set_progress() expects one argument.
  expect(nullptr, "set_progress()", kArgsParsingFailure);
  expect(nullptr, "set_progress(\"arg1\", \"arg2\")", kArgsParsingFailure);

  // Invalid progress argument.
  expect(nullptr, "set_progress(\"arg1\")", kArgsParsingFailure);
  expect(nullptr, "set_progress(\"3x+5\")", kArgsParsingFailure);
  expect(nullptr, "set_progress(\".3.5\")", kArgsParsingFailure);

  TemporaryFile tf;
  UpdaterInfo updater_info;
  updater_info.cmd_pipe = fdopen(tf.fd, "w");
  expect(".52", "set_progress(\".52\")", kNoCause, &updater_info);
  fflush(updater_info.cmd_pipe);

  std::string cmd;
  ASSERT_TRUE(android::base::ReadFileToString(tf.path, &cmd));
  ASSERT_EQ(android::base::StringPrintf("set_progress %f\n", .52), cmd);
  // recovery-updater protocol expects 2 tokens ("set_progress <frac>").
  ASSERT_EQ(2U, android::base::Split(cmd, " ").size());
}

TEST_F(UpdaterTest, show_progress) {
  // show_progress() expects two arguments.
  expect(nullptr, "show_progress()", kArgsParsingFailure);
  expect(nullptr, "show_progress(\"arg1\")", kArgsParsingFailure);
  expect(nullptr, "show_progress(\"arg1\", \"arg2\", \"arg3\")", kArgsParsingFailure);

  // Invalid progress arguments.
  expect(nullptr, "show_progress(\"arg1\", \"arg2\")", kArgsParsingFailure);
  expect(nullptr, "show_progress(\"3x+5\", \"10\")", kArgsParsingFailure);
  expect(nullptr, "show_progress(\".3\", \"5a\")", kArgsParsingFailure);

  TemporaryFile tf;
  UpdaterInfo updater_info;
  updater_info.cmd_pipe = fdopen(tf.fd, "w");
  expect(".52", "show_progress(\".52\", \"10\")", kNoCause, &updater_info);
  fflush(updater_info.cmd_pipe);

  std::string cmd;
  ASSERT_TRUE(android::base::ReadFileToString(tf.path, &cmd));
  ASSERT_EQ(android::base::StringPrintf("progress %f %d\n", .52, 10), cmd);
  // recovery-updater protocol expects 3 tokens ("progress <frac> <secs>").
  ASSERT_EQ(3U, android::base::Split(cmd, " ").size());
}
