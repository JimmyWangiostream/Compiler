Design the grammar for “if … else if … else”


創建一個 grmmar if_stat可以parse input: if(get_val){stat} else_stat
而令else_stat : 1.else if(get_val){stat} 或 
		2.else{stat} 或 
		3.空(只有if)
**get_val 為條件 