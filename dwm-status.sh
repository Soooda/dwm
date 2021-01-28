function print_date() {
	date '+%Y年%m月%d日 %H:%M'
}

xsetroot -name "$(print_date)"

exit 0
