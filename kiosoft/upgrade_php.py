#!/usr/bin/env python
# -*- coding: UTF-8 -*-

# @Time    : 2020-07-03
# @Author  : Rottens

import os
import sys
import logging
import traceback
import datetime
import platform

# compare config
COMPARE_LIST = {
    "laundry_portal": {
        "file": ["application/config/config.php", 
                 "application/config/database.php", 
                 "application/config/email.php",
                 "application/config/migration.php", 
                 "application/config/oauth2.php", 
                 "application/config/site_info.php",
                 "settings_item.md"],
        "dir": ["application/logs/task_schedulers"],
        "dir": ["application/migrations"]
    },
    "value_code": {
        "file":["application/config/config.php", 
                "application/config/database.php", 
                "application/config/email.php",
                "application/config/migration.php", 
                "application/config/site_info.php",
                "settings_item.md"],
        "dir":["application/logs/task_schedulers"],
        "dir": ["application/migrations"]
    },
    "web_rss": {
        "file":["application/config/config.php", 
                "application/config/database.php", 
                "application/config/email.php",
                "application/config/migration.php", 
                "application/config/site_info.php",
                "settings_item.md"],
        "dir":["application/logs/task_schedulers"],
        "dir": ["application/migrations"]
    },
     "web_lcms": {
        "file":["application/config/config.php", 
                "application/config/database.php", 
                "application/config/email.php",
                "application/config/migration.php", 
                "application/config/site_info.php",
                "settings_item.md"],
        "dir":["application/logs/task_schedulers"],
        "dir": ["application/migrations"]
    },
     "back_end": {
        "file":[".env", 
                "config/sms.php"],
        "dir":["public/storage/uploads/vendor"]      
    },
     "front_end": {
        "file":[".env.production"],
        "dir":["json"]
    },
}

# email config
# EMAIL_CONFIG = {
#     "HOST":"smtp.mxhichina.com",
#     "PORT":465,
#     "FROMADDR":"chengu@city229.com",
#     "PASSWORD":"",
# }
EMAIL_CONFIG = {
    "HOST":"smtp.gmail.com",
    "PORT":465,
    "FROMADDR":"noreply.washboard@gmail.com",
    "PASSWORD":"csxrjiacawvhxofo",
}

def print_flag(content, flag=0):
    if flag == 0:
        logging.info(content)
    else:
        logging.info('-' * 20 + content + '-' * 20)

def get_all_files(path):
    flist = []
    for root, dirs, fs in os.walk(path):
        for f in fs:
            if f.endswith(".log"):
        		continue
            f_fullpath = os.path.join(root, f)
            f_relativepath = f_fullpath[len(path):]
            flist.append(f_relativepath)
    return flist

def get_pre_compare_files(projectName):
    if not projectName or projectName not in COMPARE_LIST.keys():
        return {
            "file":[],
            "dir":[]
        }
    else:
        return COMPARE_LIST[projectName]

def get_file_content(fileName):
    textLines = []
    if os.path.exists(fileName):
        with open(fileName, "rb") as ff:
            commentFlag = False
            while True:
                lineinfo = ff.readline().decode('utf-8', 'ignore')
                if lineinfo == "":
                    break
                lineinfo = lineinfo.replace("\n","")
                if lineinfo == "":
                    continue
                if lineinfo.startswith("/*"):
                    if not lineinfo.endswith("*/"):
                        commentFlag = True
                    continue
                elif lineinfo.endswith("*/"):
                    commentFlag = False
                    continue
                elif lineinfo.startswith("//") or commentFlag:
                    continue
                textLines.append(lineinfo)
    return textLines

def compare_task(oldFile, newFile, isDir):
    if platform.system() == "Windows":
        oldFile = oldFile.replace("/","\\")
        newFile = newFile.replace("/","\\")

    if isDir:
        oldLines = get_all_files(oldFile)
        newLines = get_all_files(newFile)
    else:
        oldLines = get_file_content(oldFile)
        newLines = get_file_content(newFile)

    setOldVer = set(oldLines)
    setNewVer = set(newLines)
    onlyFiles = setOldVer ^ setNewVer

    onlyInOld = []
    onlyInNew = []
    for of in onlyFiles:
        if of in setNewVer:
            onlyInNew.append(of)
        else:
            onlyInOld.append(of)
    if onlyInOld:
        print_flag("old line:\n" + "\n".join(onlyInOld))
    if onlyInNew:
        print_flag("new line:\n" + "\n".join(onlyInNew))

def dir_compare(projectName, oldVerDir, newVerDir):
    compareFiles = get_pre_compare_files(projectName)
    for fileItem in compareFiles["file"]:
        print_flag("compare file: {} start ......".format(fileItem))
        compare_task(oldVerDir + fileItem, newVerDir + fileItem, False)
        print_flag("compare file: {} end ......\n".format(fileItem))

    for dirItem in compareFiles["dir"]:
        print_flag("compare file: {} start ......".format(dirItem))
        compare_task(oldVerDir + dirItem, newVerDir + dirItem, True)
        print_flag("compare file: {} end ......\n".format(dirItem))

def send_email(files, emails, subject, content):
    import smtplib
    from email.mime.multipart import MIMEMultipart
    from email.mime.application import MIMEApplication
    from email.mime.text import MIMEText

    m = MIMEMultipart()
    m['Subject'] = subject
    m['From'] = EMAIL_CONFIG["FROMADDR"]
    m['To'] = emails

    for fileItem in files:
        zipApart = MIMEApplication(open(fileItem, 'rb').read())
        if platform.system() == "Windows":
            filename = fileItem.split("\\")[-1]
        else:
            filename = fileItem.split("/")[-1]
        zipApart.add_header('Content-Disposition', 'attachment', filename=filename)
        m.attach(zipApart)
    part = MIMEText(content,_subtype='html',_charset="utf-8")
    m.attach(part)
    try:
        #server = smtplib.SMTP(EMAIL_CONFIG["HOST"],EMAIL_CONFIG["PORT"])
        #server.ehlo()
        #server.starttls()
        #server.ehlo()
        server = smtplib.SMTP_SSL(host=EMAIL_CONFIG["HOST"], port=EMAIL_CONFIG["PORT"])
        server.login(EMAIL_CONFIG["FROMADDR"], EMAIL_CONFIG["PASSWORD"])
        server.sendmail(EMAIL_CONFIG["FROMADDR"], emails.split(","), m.as_string())
        server.quit()
    except smtplib.SMTPException:
        print(traceback.format_exc())


if __name__ == '__main__':
    # sys.argv.extend(["laundry_portal",#"value_code",
    #                  "22255",
    #                  "226011",
    #                  "C:\\Users\\Administrator\\Desktop\\111\\techtrex-kiosk_laundry_portal-22255",
    #                  "C:\\Users\\Administrator\\Desktop\\111\\techtrex-kiosk_laundry_portal-226011",
    #                  "balechen@techtrex.com,eddiefan@techtrex.com"])
    # print(sys.argv)
    lockFile = "upgrade_php.lock"
    if os.path.exists(lockFile):
        print("Exist upgrading config process, please check....")
    elif len(sys.argv) < 6:
        print("Argument error, please check....")
    else:
        # script_name, project_name, old_ver_num, new_ver_num, old_dir_path, new_dir_path, email_accounts
        with open(lockFile, "w") as f:
            f.write(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        dateStr = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        logFile = 'upgrade_config_%s.log' % (dateStr,)
        logging.basicConfig(level=logging.INFO,
                            format='%(asctime)s %(filename)s %(levelname)s %(message)s',
                            datefmt='%a, %d %b %Y %H:%M:%S',
                            filename=logFile,
                            filemode='a')
        try:
            oldDir = sys.argv[4]
            newDir = sys.argv[5]
            if oldDir[-1] != "\\" and oldDir[-1] != "/":
                oldDir += "/"
            if newDir[-1] != "\\" and newDir[-1] != "/":
                newDir += "/"
            print_flag("upgrade {} start: from {} to {}".format(sys.argv[1], sys.argv[2], sys.argv[3]), flag=1)
            dir_compare(sys.argv[1], oldDir, newDir)

            # send email
            subject = "auto compare config report"
            mail_body = """
    <!DOCTYPE html>
<html>
<head></head>
<body>
    <div><strong >upgrade:</strong><span>{}</span></div>
    <div><strong >project name:</strong><span>{}</span></div>
    <div><strong >project version:</strong><span>{}</span></div>
    <br/>
</body>
</html>
    """ .format ( sys.argv[1], sys.argv[2], sys.argv[3])
    
            #content = "upgrade {} \n •project name:{}\n •project version:{}".format(sys.argv[1], sys.argv[2], sys.argv[3])
            to_emails = sys.argv[6]
            logFileName = os.path.join(os.path.dirname(os.path.realpath(__file__)),logFile)
            files = [logFileName]
            # print(files, to_emails, subject, content)
            send_email(files, to_emails, subject, mail_body)
            os.remove(logFileName)
        except:
            print(traceback.format_exc())
        finally:
            print_flag("upgrade finish", flag=1)
            os.remove(lockFile)
