package main

import (
	"database/sql"
	"fmt"
)

// 查出数据库表新增的Uvid和ULN
func selectLogUvid(databaseName string, firstDate string, lastDate string) []UvidULN {
	//查出时间段内所有的uvid
	sqlStrUvid := fmt.Sprintf("select DISTINCT Uvid from %s.account_refill_log where datetime between \"%s\" and \"%s\"", databaseName, firstDate, lastDate)
	var uvidList []int64 //记录Uvid
	err := DB.Select(&uvidList, sqlStrUvid)

	if err != nil {
		fmt.Printf("r04 query failed,err:%v\n", err)
		return nil
	}

	//遍历全表筛选出新增的uvid
	sqlStrNewUvid := fmt.Sprintf("select Uvid from %s.account_refill_log where \"%s\" > datetime and Uvid = ?", databaseName, firstDate)
	var uvid int64
	var newUvid []int64
	for _, v := range uvidList {
		err := DB.Get(&uvid, sqlStrNewUvid, v)
		if err == sql.ErrNoRows {
			newUvid = append(newUvid, v)
		} else if err != nil {
			fmt.Printf("r04 query failed,err:%v\n", err)
			return nil
		}
	}
	//fmt.Printf("新增的uvid:%v\n", newUvid)
	//查出新增的Uvid与ULN
	sqlStrUvidULN := fmt.Sprintf("select DISTINCT uvid,ULN from %s.account_refill_log where datetime between \"%s\" and \"%s\" and Uvid = ?", databaseName, firstDate, lastDate)
	var uvidULN UvidULN
	var uvidULNList []UvidULN
	//	fmt.Print(sqlStrUvidULN)
	for _, v := range newUvid {
		err := DB.Get(&uvidULN, sqlStrUvidULN, v)
		if err != nil {
			fmt.Printf("r04查出新Uvid与ULN query failed,err:%v\n", err)
			return nil
		}
		//	fmt.Printf("uvidULN:%#v\n", uvidULN)
		uvidULNList = append(uvidULNList, uvidULN)
	}

	return uvidULNList

}
