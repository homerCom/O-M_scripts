package main

import (
	"database/sql"
	"fmt"
)

// 导出Excel文档时的uvid数据结构
type UvidULN struct {
	Uvid int64  `db:"uvid"`
	ULN  string `db:"ULN"`
}

type TmIDUvidUln struct {
	TerminalID string `db:"TerminalID"`
	Uvid       int64  `db:"uvid"`
	ULN        string `db:"ULN"`
}

// 查出数据库表新增的Uvid和ULN
func selectu04Uvid(databaseName string, firstDate string, lastDate string) []UvidULN {
	//查出时间段内所有的uvid
	sqlStrUvid := fmt.Sprintf("select DISTINCT Uvid from %s.u04  where TransTime between \"%s\" and \"%s\"", databaseName, firstDate, lastDate)
	var uvidList []int64 //记录Uvid
	//	fmt.Print(sqlStrUvid)
	err := DB.Select(&uvidList, sqlStrUvid)

	if err != nil {
		fmt.Printf("query failed,err:%v\n", err)
		return nil
	}

	//遍历全表筛选出新增的uvid
	sqlStrNewUvid := fmt.Sprintf("select Uvid from %s.u04 where \"%s\" > TransTime and Uvid = ?", databaseName, firstDate)
	var uvid int64
	var newUvid []int64
	for _, v := range uvidList {
		err := DB.Get(&uvid, sqlStrNewUvid, v)
		if err == sql.ErrNoRows {
			newUvid = append(newUvid, v)
		} else if err != nil {
			fmt.Printf("query failed,err:%v\n", err)
			return nil
		}
	}
	//fmt.Printf("新增的uvid:%v\n", newUvid)
	//查出新增的Uvid与ULN
	sqlStrUvidULN := fmt.Sprintf("select DISTINCT uvid,ULN from %s.u04 where TransTime between \"%s\" and \"%s\" and Uvid = ?", databaseName, firstDate, lastDate)
	var uvidULN UvidULN
	var uvidULNList []UvidULN
	//fmt.Print(sqlStrUvidULN)
	for _, v := range newUvid {
		err := DB.Get(&uvidULN, sqlStrUvidULN, v)
		if err != nil {
			fmt.Printf("查出新Uvid与ULN query failed,err:%v\n", err)
			return nil
		}
		//	fmt.Printf("uvidULN:%#v\n", uvidULN)
		uvidULNList = append(uvidULNList, uvidULN)
	}

	return uvidULNList

}

// 查出数据库U04表新增的TerminalID
func selectU04TerminalID(databaseName string, firstDate string, lastDate string) []TmIDUvidUln {
	//列出所有的TerminalID
	sqlStr := fmt.Sprintf("select DISTINCT TerminalID from %s.u04 where TransTime between \"%s\" and \"%s\"", databaseName, firstDate, lastDate)
	var tmIDList []string
	err := DB.Select(&tmIDList, sqlStr)

	if err != nil {
		fmt.Printf("query failed,err:%v\n", err)
		return nil
	}
	//	fmt.Printf("list:%#v\n", tmIDList)

	//查出新增的TerminalID
	sqlStrNewTerminalID := fmt.Sprintf("select TerminalID from %s.u04 where \"%s\" > TransTime and TerminalID = ?", databaseName, firstDate)
	var tmid string
	var newTmID []string
	for _, v := range tmIDList {
		err := DB.Get(&tmid, sqlStrNewTerminalID, v)
		if err == sql.ErrNoRows {
			newTmID = append(newTmID, v)
		} else if err != nil {
			fmt.Printf("查新增TerminalID query failed,err:%v\n", err)
			return nil
		}
	}
	//	fmt.Printf("新增的TerminalID是:%#v\n", newTmID)

	//查出新增的TerminalID,uvid,ULN
	sqlStrTmIDUvidULN := fmt.Sprintf("select DISTINCT TerminalID,uvid,ULN from %s.u04 where TransTime between \"%s\" and \"%s\" and TerminalID = ?", databaseName, firstDate, lastDate)
	var TmIDUvidULN TmIDUvidUln
	var TmIDUvidULNList []TmIDUvidUln

	for _, v := range newTmID {
		err := DB.Get(&TmIDUvidULN, sqlStrTmIDUvidULN, v)
		if err != nil {
			fmt.Printf("查出新Uvid与ULN query failed,err:%v\n", err)
			return nil
		}
		TmIDUvidULNList = append(TmIDUvidULNList, TmIDUvidULN)
		//fmt.Printf("TmIDUvidULN:%#v\n", TmIDUvidULN)
	}

	return TmIDUvidULNList
}
