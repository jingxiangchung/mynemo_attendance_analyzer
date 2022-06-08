#!/bin/bash
#Check attendance
#Prerequisite: install pdftotext

glists='K1_final_list.csv K2_final_list.csv'	#Name list for groups output from get_students_list.sh
afolder='Attendance'							#Path to the folder storing your raw attendance pdf files printed from MyNemo (Akademik->Modul Pensyarah->QR Kod Kehadiran)

for ifile in `ls ${afolder}/*.pdf`; do

	if [[ ! -f ${ifile%.pdf}.txt ]]; then
		pdftotext -layout ${ifile}
				
		class_dateline=`grep -n "Class Date" ${ifile%.pdf}.txt | cut -d ":" -f 1`
		class_date=`sed -n $((class_dateline+2))p < ${ifile%.pdf}.txt | awk '{print $2}'`
		datestr=`date -d ${class_date} +%Y%m%d`
		
		count=1
		for g in ${glists}; do
			
			if [[ -f ${afolder}/${datestr}_K${count}.csv ]]; then

				cat ${g} | tail -n +2 | while IFS=, read -r  matrix name; do
					check=`grep ${matrix} ${ifile%.pdf}.txt`
					[[ ${check} == "" ]] && echo 0 >> ${afolder}/${datestr}_K${count}.csv.tmp1 || echo 1 >> ${afolder}/${datestr}_K${count}.csv.tmp1				
				done
				
				paste ${afolder}/${datestr}_K${count}.csv ${afolder}/${datestr}_K${count}.csv.tmp1 | awk '{print $1+$2}' | sed 's/2/1/g' > ${afolder}/${datestr}_K${count}.csv.tmp2
				mv ${afolder}/${datestr}_K${count}.csv.tmp2 ${afolder}/${datestr}_K${count}.csv
						rm ${afolder}/${datestr}_K${count}.csv.tmp1
			
			else
			
				cat ${g} | tail -n +2 | while IFS=, read -r  matrix name; do
					check=`grep ${matrix} ${ifile%.pdf}.txt`
					[[ ${check} == "" ]] && echo 0 >> ${afolder}/${datestr}_K${count}.csv || echo 1 >> ${afolder}/${datestr}_K${count}.csv
				done
				
			fi

			count=$((count+1))
		done
		
	else
		echo "File: ${ifile%.pdf}.txt detected! Attendance should had taken, if it haven't, remove ${ifile%.pdf}.txt..."
	fi

done

echo "Job completed!"
