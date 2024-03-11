package main

import (
	"fmt"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
)

/*
四个市场数据库名称
*/
const CleanStoreLaundryDatabaseName = "check_cleanstore_laundry"
const CleanStoreVCDatabaseName = "check_cleanstore_value_code"
const IntegrateLaundryDatabaseName = "check_integration_laundry"
const IntegrateVCDatabaseName = "check_integration_value_code"
const AmusementLaundryDatabaseName = "check_amusement_laundry"
const AmusementVCDatabaseName = "check_amusement_value_code"
const InternationalLaundryDatabaseName = "check_international_laundry"
const InternationalVCDatabaseName = "check_international_value_code"

var databaseHostName = "azure-retailstage.mariadb.database.azure.com"
var databaseUserName = "report@azure-retailstage"
var databasePassword = "123456"
var databasePort = "3306"

//获取本周周一的日期

func GetFirstDateOfWeek() (weekMonday string) {
	now := time.Now()

	offset := int(time.Monday - now.Weekday())
	if offset > 0 {
		offset = -6
	}

	weekStartDate := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Local).AddDate(0, 0, offset)
	weekMonday = weekStartDate.Format("2006-01-02")
	return

}

// 获取上周周一的日期
func GetLastWeekFirstDate() (weekMonday string) {
	thisWeekMonday := GetFirstDateOfWeek()
	TimeMonday, _ := time.Parse("2006-01-02", thisWeekMonday)
	lastWeekMonday := TimeMonday.AddDate(0, 0, -7)
	weekMonday = lastWeekMonday.Format("2006-01-02")
	return

}

// 获取上周周日的日期
func GetLastWeekLastDate() (weekMonday string) {
	thisWeekMonday := GetFirstDateOfWeek()
	TimeMonday, _ := time.Parse("2006-01-02", thisWeekMonday)
	lastWeekMonday := TimeMonday.AddDate(0, 0, -1)
	weekMonday = lastWeekMonday.Format("2006-01-02")
	return

}

var firstDate = GetLastWeekFirstDate()
var lastDate = GetFirstDateOfWeek()
var lasterweekdays = GetLastWeekLastDate()

var ExcelFile = "RetailData" + "_" + firstDate + "_" + lasterweekdays + ".xlsx"

var DB *sqlx.DB

func initDB() (err error) {

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True", databaseUserName, databasePassword, databaseHostName, databasePort, CleanStoreLaundryDatabaseName)
	DB, err = sqlx.Connect("mysql", dsn)
	if err != nil {
		fmt.Printf("connect DB failed,err:%v\n", err)
		return
	}
	DB.SetMaxOpenConns(20)
	DB.SetMaxIdleConns(10)
	fmt.Println("connecting to MySQL...")
	return
}

func main() {

	currentTime := time.Now()
	fmt.Println("Current Time:", currentTime)
	if err := initDB(); err != nil {
		fmt.Printf("init DB failed ,err:%v\n", err)
		return
	}
	fmt.Println("init DB sssuccesss...")
	defer DB.Close()

	//获取CleanStore新增的uvid与ULN
	cleanStoreU04UvidAndULN := selectu04Uvid(CleanStoreLaundryDatabaseName, firstDate, lastDate)
	cleanStoreR04UvidAndULN := selectR04Uvid(CleanStoreLaundryDatabaseName, firstDate, lastDate)
	cleanStoreLogUvidAndULN := selectLogUvid(CleanStoreVCDatabaseName, firstDate, lastDate)
	cleanstoreU04TmIDUvidUln := selectU04TerminalID(CleanStoreLaundryDatabaseName, firstDate, lastDate)
	cleanStoreR04TmIDUvidUln := selectR04TerminalID(CleanStoreLaundryDatabaseName, firstDate, lastDate)
	//去重cleanStore UVID
	cleanstoreU04uvid, cleanstoreR04uvid, cleanstoreLoguvid := distinctUvid(cleanStoreU04UvidAndULN, cleanStoreR04UvidAndULN, cleanStoreLogUvidAndULN)
	//去重cleanStore TerminalID
	cleanstoreU04Tm, cleanstoreR04Tm := distinctTmID(cleanstoreU04TmIDUvidUln, cleanStoreR04TmIDUvidUln)
	//创建excel
	createExcel(ExcelFile)
	//将CleanStore写入excel
	SetExcelColWidth(ExcelFile, "Cleanstore")
	writeExcelUvidULN(ExcelFile, "Cleanstore", "U04", cleanstoreU04uvid)
	writeExcelUvidULN(ExcelFile, "Cleanstore", "R04", cleanstoreR04uvid)
	writeExcelUvidULN(ExcelFile, "Cleanstore", "account_refill_log", cleanstoreLoguvid)
	writeExcelTerminalID(ExcelFile, "Cleanstore", "U04", cleanstoreU04Tm)
	writeExcelTerminalID(ExcelFile, "Cleanstore", "R04", cleanstoreR04Tm)
	//fmt.Printf("Clean Store U04 Uvid list:%#v\n", cleanStoreU04UvidAndULN)
	//获取integration新增的uvid与ULN
	integrationU04UvidAndULN := selectu04Uvid(IntegrateLaundryDatabaseName, firstDate, lastDate)
	integrationR04UvidAndULN := selectR04Uvid(IntegrateLaundryDatabaseName, firstDate, lastDate)
	integrationLogUvidAndULN := selectLogUvid(IntegrateVCDatabaseName, firstDate, lastDate)
	integrationU04TmIDUvidUln := selectU04TerminalID(IntegrateLaundryDatabaseName, firstDate, lastDate)
	integrationR04TmIDUvidUln := selectR04TerminalID(IntegrateLaundryDatabaseName, firstDate, lastDate)
	//去重integration UVID
	integrationU04uvid, integrationR04uvid, integrationLoguvid := distinctUvid(integrationU04UvidAndULN, integrationR04UvidAndULN, integrationLogUvidAndULN)
	//去重integration TerminalID
	integrationU04Tm, integrationR04Tm := distinctTmID(integrationU04TmIDUvidUln, integrationR04TmIDUvidUln)
	//将integration写入excel
	SetExcelColWidth(ExcelFile, "Integration")
	writeExcelUvidULN(ExcelFile, "Integration", "U04", integrationU04uvid)
	writeExcelUvidULN(ExcelFile, "Integration", "R04", integrationR04uvid)
	writeExcelUvidULN(ExcelFile, "Integration", "account_refill_log", integrationLoguvid)
	writeExcelTerminalID(ExcelFile, "Integration", "U04", integrationU04Tm)
	writeExcelTerminalID(ExcelFile, "Integration", "R04", integrationR04Tm)

	//获取Amusement新增的uvid与ULN
	amusementU04UvidAndULN := selectu04Uvid(AmusementLaundryDatabaseName, firstDate, lastDate)
	amusementR04UvidAndULN := selectR04Uvid(AmusementLaundryDatabaseName, firstDate, lastDate)
	amusementLogUvidAndULN := selectLogUvid(AmusementVCDatabaseName, firstDate, lastDate)

	amusementU04TmIDUvidUln := selectU04TerminalID(AmusementLaundryDatabaseName, firstDate, lastDate)
	//	amusementU04TmIDUvidUln := selectU04TerminalID(AmusementLaundryDatabaseName, "2023-06-08", "2023-06-09")
	//fmt.Printf(" U04 Uvid list:%#v\n", amusementU04TmIDUvidUln)
	amusementR04TmIDUvidUln := selectR04TerminalID(AmusementLaundryDatabaseName, firstDate, lastDate)
	//	amusementR04TmIDUvidUln := selectR04TerminalID(AmusementLaundryDatabaseName, "2023-06-08", "2023-06-09")
	//	fmt.Printf(" R04 Uvid list:%#v\n", amusementU04TmIDUvidUln)
	//去重Amusement UVID
	amusementU04uvid, amusementR04uvid, amusementLoguvid := distinctUvid(amusementU04UvidAndULN, amusementR04UvidAndULN, amusementLogUvidAndULN)
	//去重Amusement TerminalID
	amusementU04Tm, amusementR04Tm := distinctTmID(amusementU04TmIDUvidUln, amusementR04TmIDUvidUln)
	//	fmt.Printf(" U04 去重 list:%#v\n", amusementU04Tm)
	//	fmt.Printf(" R04 去重 list:%#v\n", amusementR04Tm)
	//将Amusement写入excel
	SetExcelColWidth(ExcelFile, "Amusement")
	writeExcelUvidULN(ExcelFile, "Amusement", "U04", amusementU04uvid)
	writeExcelUvidULN(ExcelFile, "Amusement", "R04", amusementR04uvid)
	writeExcelUvidULN(ExcelFile, "Amusement", "account_refill_log", amusementLoguvid)
	writeExcelTerminalID(ExcelFile, "Amusement", "U04", amusementU04Tm)
	writeExcelTerminalID(ExcelFile, "Amusement", "R04", amusementR04Tm)

	//获取international新增的uvid与ULN
	internationalU04UvidAndULN := selectu04Uvid(InternationalLaundryDatabaseName, firstDate, lastDate)
	internationalR04UvidAndULN := selectR04Uvid(InternationalLaundryDatabaseName, firstDate, lastDate)
	internationalLogUvidAndULN := selectLogUvid(InternationalVCDatabaseName, firstDate, lastDate)
	internationalU04TmIDUvidUln := selectU04TerminalID(InternationalLaundryDatabaseName, firstDate, lastDate)
	internationalR04TmIDUvidUln := selectR04TerminalID(InternationalLaundryDatabaseName, firstDate, lastDate)
	//去重international UVID
	internationalU04uvid, internationalR04uvid, internationalLoguvid := distinctUvid(internationalU04UvidAndULN, internationalR04UvidAndULN, internationalLogUvidAndULN)
	//去重international TerminalID
	internationalU04Tm, internationalR04Tm := distinctTmID(internationalU04TmIDUvidUln, internationalR04TmIDUvidUln)
	//将international写入excel
	SetExcelColWidth(ExcelFile, "International")
	writeExcelUvidULN(ExcelFile, "International", "U04", internationalU04uvid)
	writeExcelUvidULN(ExcelFile, "International", "R04", internationalR04uvid)
	writeExcelUvidULN(ExcelFile, "International", "account_refill_log", internationalLoguvid)
	writeExcelTerminalID(ExcelFile, "International", "U04", internationalU04Tm)
	writeExcelTerminalID(ExcelFile, "International", "R04", internationalR04Tm)

	endTime := time.Now()
	fmt.Println("Current Time:", endTime)
	// fmt.Printf("Clean Store U04 Uvid list:%#v\n", cleanStoreU04UvidAndULN)
	//cleanstoreU04TmIDUvidUln := selectU04TerminalID(CleanStoreLaundryDatabaseName, firstDate, lastDate)
	//fmt.Printf("Clean Store U04 Uvid list:%#v\n", cleanstoreU04TmIDUvidUln)

	// cleanStoreR04UvidAndULN := selectR04Uvid(CleanStoreLaundryDatabaseName, "16")
	// fmt.Printf("Clean Store R04 Uvid list:%#v\n", cleanStoreR04UvidAndULN)
	// cleanStoreR04TmIDUvidUln := selectR04TerminalID(CleanStoreLaundryDatabaseName, "16")
	// fmt.Printf("Clean Store R04 Uvid list:%#v\n", cleanStoreR04TmIDUvidUln)

	// cleanStoreLogUvidAndULN := selectLogUvid(CleanStoreVCDatabaseName, "15")
	// fmt.Printf("Clean Store Log Uvid list:%#v\n", cleanStoreLogUvidAndULN)

	//测试uvid去重
	// cleanStoreU04UvidAndULN := []UvidULN{{Uvid: 9001, ULN: "100040611"}, {Uvid: 9002, ULN: "100040611"}, {Uvid: 9003, ULN: "100040611"}, {Uvid: 9111, ULN: "100040611"}}
	// cleanStoreR04UvidAndULN := []UvidULN{{Uvid: 9003, ULN: "100040611"}, {Uvid: 9004, ULN: "100040611"}, {Uvid: 9005, ULN: "100040611"}, {Uvid: 9006, ULN: "100040611"}}
	// cleanStoreLogUvidAndULN := []UvidULN{{Uvid: 9006, ULN: "100040611"}, {Uvid: 9007, ULN: "100040611"}, {Uvid: 9002, ULN: "100040611"}, {Uvid: 9008, ULN: "100040611"}}
	//distinctUvid(cleanStoreU04UvidAndULN, cleanStoreR04UvidAndULN, cleanStoreLogUvidAndULN)
	//fmt.Printf("Clean Store Log Uvid agen list:%#v\n", cleanStoreLogUvidAndULN)
	//测试TerminalID去重
	// cleanStoreU04TmIDUvidUln := []TmIDUvidUln{{TerminalID: "00000000", Uvid: 83047, ULN: "100000069"}, {TerminalID: "00000001", Uvid: 83047, ULN: "100000069"}, {TerminalID: "00022000", Uvid: 83047, ULN: "100000069"}, {TerminalID: "00000033", Uvid: 83047, ULN: "100000069"}}
	// cleanStoreR04TmIDUvidUln := []TmIDUvidUln{{TerminalID: "00000013", Uvid: 83047, ULN: "100000069"}, {TerminalID: "00000001", Uvid: 83047, ULN: "100000069"}, {TerminalID: "00000033", Uvid: 83047, ULN: "100000069"}, {TerminalID: "00000003", Uvid: 83047, ULN: "100000069"}}

	//distinctTmID(cleanStoreU04TmIDUvidUln, cleanStoreR04TmIDUvidUln)
	//createExcel()

	// SetExcelColWidth("RetailData.xlsx", "Integration")
	// writeExcelUvidULN("RetailData.xlsx", "Integration", "U04", cleanStoreU04UvidAndULN)
	// writeExcelUvidULN("RetailData.xlsx", "Integration", "R04", cleanStoreR04UvidAndULN)
	// writeExcelUvidULN("RetailData.xlsx", "Integration", "account_refill_log", cleanStoreLogUvidAndULN)
	// writeExcelTerminalID("RetailData.xlsx", "Integration", "U04", cleanStoreU04TmIDUvidUln)
	// writeExcelTerminalID("RetailData.xlsx", "Integration", "R04", cleanStoreR04TmIDUvidUln)

	// SetExcelColWidth("RetailData.xlsx", "Amusement")
	// writeExcelUvidULN("RetailData.xlsx", "Amusement", "U04", cleanStoreU04UvidAndULN)
	// writeExcelUvidULN("RetailData.xlsx", "Amusement", "R04", cleanStoreR04UvidAndULN)
	// writeExcelUvidULN("RetailData.xlsx", "Amusement", "account_refill_log", cleanStoreLogUvidAndULN)
	// writeExcelTerminalID("RetailData.xlsx", "Amusement", "U04", cleanStoreU04TmIDUvidUln)
	// writeExcelTerminalID("RetailData.xlsx", "Amusement", "R04", cleanStoreR04TmIDUvidUln)

	// SetExcelColWidth("RetailData.xlsx", "International")
	// writeExcelUvidULN("RetailData.xlsx", "International", "U04", cleanStoreU04UvidAndULN)
	// writeExcelUvidULN("RetailData.xlsx", "International", "R04", cleanStoreR04UvidAndULN)
	// writeExcelUvidULN("RetailData.xlsx", "International", "account_refill_log", cleanStoreLogUvidAndULN)
	// writeExcelTerminalID("RetailData.xlsx", "International", "U04", cleanStoreU04TmIDUvidUln)
	// writeExcelTerminalID("RetailData.xlsx", "International", "R04", cleanStoreR04TmIDUvidUln)

}

//u04表DISTINCT  distinct
//第一步,拿7天内的uvid

//第二步，遍历全表筛选出新增的uvid

// 第三步     Uvid和 ULN

//第三步,查出7天内的TerminalID
//第四步，遍历全表筛选出新增的TerminalID

//r04表
//第一步,拿7天内的uvid 和 ULN
//第二步，遍历全表筛选出新增的uvid
//第三步,查出7天内的TerminalID
//第四步，遍历全表筛选出新增的TerminalID

//account_refill_log表
//第五步,查出7天内的uvid

//三个表数据去重，然后写入Excel

//创建excel 文档

//改sheet 表名字 sheet1 Cleanstore , sheet2 Integration ,sheet3  Amusement ,sheet4 International

//设置 u04 r04 account_refill_log表格式

//写入数据 Cleanstore integration amusement international

//去重返回切片数据
//判断切片是否为空
//写TerminalID的Excel

//改日期为上周一到周日
//文件名字加日期
//导数据库，正式运行
//跨平台编译
