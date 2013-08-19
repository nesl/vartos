#!/bin/bash
for file in *eps
do
	echo Processing $file
	epstopdf $file
	pdffile=`echo "${file}" | sed 's/eps/pdf/g'`
	pdftk $pdffile cat 1E output "${pdffile}-proc"
	pdfcrop "${pdffile}-proc" $pdffile > /dev/null
	rm "${pdffile}-proc"
done
