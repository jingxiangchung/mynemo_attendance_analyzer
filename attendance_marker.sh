#!/bin/bash
#Attendence marker
#Prerequisite: install pdftotext

glists='K1_final_list.csv K2_final_list.csv'	#Name list for groups output from get_students_list.sh
afolder='Attendance'							#Path to the folder storing your raw attendance pdf files printed from MyNemo (Akademik->Modul Pensyarah->QR Kod Kehadiran)

#----------------------------------------------

count=1
for g in ${glists}; do

	for afile in `ls ${afolder}/????????_K${count}.csv`; do
	
		datestr=`basename ${afile} | cut -d "_" -f 1`
		chkdate=`grep ${datestr} ${g}`

		if [[ ${chkdate} == "" ]]; then
		
			echo ${datestr} > ${datestr}_K${count}.csv.date
			cat ${afile} >> ${datestr}_K${count}.csv.date
		
			paste -d "," ${g} ${datestr}_K${count}.csv.date > ${g}.tmp
			mv ${g}.tmp ${g}; 
			rm ${datestr}_K${count}.csv.date
			
		else
			echo "Attendance for ${datestr} is marked! Skip!"
		fi

	done

	tcol=`head -n 1 ${g} | sed 's/,/ /g' | wc -w`
	tdate=$((tcol-2))
	
	echo "Percentage" > ${g}_percent_count
	cat ${g} | tail -n +2 | cut -d "," -f 3- | while read -r num; do
	
		acount=`echo ${num} | tr ',' '\n' | awk '{ sum += $1 }; END { print sum }'`
		echo ${acount} ${tdate} | awk -F " " '{printf "%.1f\n",  $1/$2*100}' >> ${g}_percent_count		
		
	done
	
	paste -d "," ${g} ${g}_percent_count > complete_${g}
		rm ${g}_percent_count
	
	count=$((count+1))
done

echo "Job completed!"