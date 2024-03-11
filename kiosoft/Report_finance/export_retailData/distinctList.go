package main

// Uvid去重
func distinctUvid(Alist, Blist, Clist []UvidULN) (u04 []UvidULN, r04 []UvidULN, account_refill_log []UvidULN) {
	if len(Alist) != 0 && len(Blist) != 0 {
		for _, v := range Alist {

			for tk, tv := range Blist {
				if v.Uvid == tv.Uvid {
					Blist = append(Blist[:tk], Blist[tk+1:]...)
				}
			}
		}
		//	fmt.Printf("第一次对比结果 list:%#v\n", Blist)
	}

	if len(Alist) != 0 && len(Clist) != 0 {
		for _, v := range Alist {

			for tk, tv := range Clist {
				if v.Uvid == tv.Uvid {
					Clist = append(Clist[:tk], Clist[tk+1:]...)
				}
			}
		}
		//	fmt.Printf("第二次对比结果 list:%#v\n", Blist)
	}

	if len(Clist) != 0 && len(Blist) != 0 {
		for _, v := range Clist {
			for tk, tv := range Blist {
				if v.Uvid == tv.Uvid {
					Blist = append(Blist[:tk], Blist[tk+1:]...)
				}
			}
		}
		//	fmt.Printf("第三次对比结果 list:%#v\n", Blist)
	}

	return Alist, Blist, Clist

	// fmt.Printf("Alist结果 list:%#v\n", Alist)
	// fmt.Printf("Blist结果 list:%#v\n", Blist)
	// fmt.Printf("Clist结果 list:%#v\n", Clist)

}

// TerminalID去重
func distinctTmID(Alist, Blist []TmIDUvidUln) (u04 []TmIDUvidUln, r04 []TmIDUvidUln) {
	if len(Alist) != 0 && len(Blist) != 0 {
		for _, v := range Alist {

			for tk, tv := range Blist {
				if v.TerminalID == tv.TerminalID {
					Blist = append(Blist[:tk], Blist[tk+1:]...)
				}
			}
		}
		//	fmt.Printf("第一次对比结果 list:%#v\n", Blist)
	}
	return Alist, Blist
	// fmt.Printf("Alist结果 list:%#v\n", Alist)
	// fmt.Printf("Blist结果 list:%#v\n", Blist)

}
