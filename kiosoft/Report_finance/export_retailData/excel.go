package main

import (
	"fmt"
	"strconv"

	"github.com/xuri/excelize/v2"
)

// 创建Excel表格
func createExcel(excelname string) {
	f := excelize.NewFile()
	defer func() {
		if err := f.Close(); err != nil {
			fmt.Println(err)
		}
	}()
	// 设置工作表sheet1 名称为Cleanstore
	sheet1err := f.SetSheetName("Sheet1", "Cleanstore")
	if sheet1err != nil {
		fmt.Println(sheet1err)
		return
	}
	// 创建Integration工作表
	_, Integrationerr := f.NewSheet("Integration")
	if Integrationerr != nil {
		fmt.Println(Integrationerr)
		return
	}

	// 创建Amusement工作表
	_, Amusementerr := f.NewSheet("Amusement")
	if Amusementerr != nil {
		fmt.Println(Amusementerr)
		return
	}

	// 创建International工作表
	_, Internationalerr := f.NewSheet("International")
	if Internationalerr != nil {
		fmt.Println(Internationalerr)
		return
	}

	if err := f.SaveAs(excelname); err != nil {
		fmt.Println(err)
	}
	f.Close()
}

func SetExcelColWidth(filename string, sheetName string) {

	f, err := excelize.OpenFile(filename)
	if err != nil {
		return
	}
	//设置列宽
	f.SetColWidth(sheetName, "A", "A", 3)
	f.SetColWidth(sheetName, "D", "D", 3)
	f.SetColWidth(sheetName, "G", "G", 3)
	f.SetColWidth(sheetName, "J", "J", 3)
	f.SetColWidth(sheetName, "N", "N", 3)

	for _, v := range []string{"B", "C", "E", "F", "H", "I", "K", "L", "M", "O", "P", "Q"} {
		if f.SetColWidth(sheetName, v, v, 12); err != nil {
			return
		}
	}

	f.Save()
	f.Close()
}

// 写入uvid与ULN到Excel
func writeExcelUvidULN(fileName string, sheetName string, tableName string, listName []UvidULN) {

	//打开文件
	f, err := excelize.OpenFile(fileName)
	if err != nil {
		return
	}

	//设置当前sheet
	index, err := f.GetSheetIndex(sheetName)
	if err != nil {
		return
	}
	f.SetActiveSheet(index)
	//设置单元格背景与边框样式
	style1, err := f.NewStyle(&excelize.Style{
		Alignment: &excelize.Alignment{Horizontal: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "000000", Style: 1},
			{Type: "top", Color: "000000", Style: 1},
			{Type: "bottom", Color: "000000", Style: 1},
			{Type: "right", Color: "000000", Style: 1}},
		Fill: excelize.Fill{Type: "pattern", Color: []string{"c0c0c0"}, Pattern: 1},
	})

	//设置单元格边框

	sytle2, err := f.NewStyle(&excelize.Style{

		Border: []excelize.Border{
			{Type: "left", Color: "000000", Style: 1},
			{Type: "top", Color: "000000", Style: 1},
			{Type: "bottom", Color: "000000", Style: 1},
			{Type: "right", Color: "000000", Style: 1}},
	})
	if err != nil {
		fmt.Println(err)
	}

	col := "B"
	switch tableName {
	case "U04":
		col = "B"
		err := f.MergeCell(sheetName, "B2", "C2")
		if err != nil {
			return
		}
		f.SetCellValue(sheetName, "B2", "U04 Uvids")
		f.SetCellValue(sheetName, "B3", "UVID")
		f.SetCellValue(sheetName, "C3", "ULN")
		err = f.SetCellStyle(sheetName, "B2", "C2", style1)
		err = f.SetCellStyle(sheetName, "B3", fmt.Sprintf("C%s", strconv.FormatInt(int64(len(listName)+3), 10)), sytle2)

	case "R04":
		col = "E"
		err := f.MergeCell(sheetName, "E2", "F2")
		if err != nil {
			return
		}
		f.SetCellValue(sheetName, "E2", "R04 Uvids")
		f.SetCellValue(sheetName, "E3", "UVID")
		f.SetCellValue(sheetName, "F3", "ULN")
		err = f.SetCellStyle(sheetName, "E2", "F2", style1)
		err = f.SetCellStyle(sheetName, "E3", fmt.Sprintf("F%s", strconv.FormatInt(int64(len(listName)+3), 10)), sytle2)
	case "account_refill_log":
		col = "H"
		err := f.MergeCell(sheetName, "H2", "I2")
		if err != nil {
			return
		}
		f.SetCellValue(sheetName, "H2", "Account_refill_log Uvids")
		f.SetCellValue(sheetName, "H3", "UVID")
		f.SetCellValue(sheetName, "I3", "ULN")
		err = f.SetCellStyle(sheetName, "H2", "I2", style1)
		err = f.SetCellStyle(sheetName, "H3", fmt.Sprintf("I%s", strconv.FormatInt(int64(len(listName)+3), 10)), sytle2)
	}

	var slicList [][]string

	for _, row := range listName {

		slicList = append(slicList, []string{strconv.FormatInt(int64(row.Uvid), 10), row.ULN})

	}

	//写入数据
	for i, row := range slicList {
		startCell, err := excelize.JoinCellName(col, 4+i)
		if err != nil {
			fmt.Print("JoinCellName", err)
			return
		}

		fmt.Printf(startCell)
		if err := f.SetSheetRow(sheetName, startCell, &row); err != nil {
			fmt.Print("setsheetrow", err)
			return
		}

	}

	f.Save()
	f.Close()
}

//写TerminalID到Excel

func writeExcelTerminalID(fileName string, sheetName string, tableName string, listName []TmIDUvidUln) {

	//打开文件
	f, err := excelize.OpenFile(fileName)
	if err != nil {
		return
	}

	//设置当前sheet
	index, err := f.GetSheetIndex(sheetName)
	if err != nil {
		return
	}
	f.SetActiveSheet(index)
	//设置单元格背景与边框样式
	style1, err := f.NewStyle(&excelize.Style{
		Alignment: &excelize.Alignment{Horizontal: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "000000", Style: 1},
			{Type: "top", Color: "000000", Style: 1},
			{Type: "bottom", Color: "000000", Style: 1},
			{Type: "right", Color: "000000", Style: 1}},
		Fill: excelize.Fill{Type: "pattern", Color: []string{"c0c0c0"}, Pattern: 1},
	})

	//设置单元格边框

	sytle2, err := f.NewStyle(&excelize.Style{

		Border: []excelize.Border{
			{Type: "left", Color: "000000", Style: 1},
			{Type: "top", Color: "000000", Style: 1},
			{Type: "bottom", Color: "000000", Style: 1},
			{Type: "right", Color: "000000", Style: 1}},
	})
	if err != nil {
		fmt.Println(err)
	}
	//设置开始列
	col := "K"
	switch tableName {
	case "U04":
		col = "K"
		err := f.MergeCell(sheetName, "K2", "M2")
		if err != nil {
			return
		}
		f.SetCellValue(sheetName, "K2", "U04 TerminalIDs")
		f.SetCellValue(sheetName, "K3", "TerminalID")
		f.SetCellValue(sheetName, "L3", "UVID")
		f.SetCellValue(sheetName, "M3", "ULN")
		err = f.SetCellStyle(sheetName, "K2", "M2", style1)
		err = f.SetCellStyle(sheetName, "K3", fmt.Sprintf("M%s", strconv.FormatInt(int64(len(listName)+3), 10)), sytle2)

	case "R04":
		col = "O"
		err := f.MergeCell(sheetName, "O2", "Q2")
		if err != nil {
			return
		}
		f.SetCellValue(sheetName, "O2", "R04 TerminalIDs")
		f.SetCellValue(sheetName, "O3", "TerminalID")
		f.SetCellValue(sheetName, "P3", "UVID")
		f.SetCellValue(sheetName, "Q3", "ULN")
		err = f.SetCellStyle(sheetName, "o2", "Q2", style1)
		err = f.SetCellStyle(sheetName, "O3", fmt.Sprintf("Q%s", strconv.FormatInt(int64(len(listName)+3), 10)), sytle2)
	}

	var slicList [][]string

	for _, row := range listName {

		slicList = append(slicList, []string{row.TerminalID, strconv.FormatInt(int64(row.Uvid), 10), row.ULN})

	}

	//写入数据
	for i, row := range slicList {
		startCell, err := excelize.JoinCellName(col, 4+i)
		if err != nil {
			fmt.Print("JoinCellName", err)
			return
		}

		if err := f.SetSheetRow(sheetName, startCell, &row); err != nil {
			fmt.Print("setsheetrow", err)
			return
		}

	}
	index2, err := f.GetSheetIndex("Cleanstore")
	if err != nil {
		return
	}
	f.SetActiveSheet(index2)
	f.Save()
	f.Close()
}
