#!/bin/bash
#
# Ex: bash lexc_extract.sh NP-TOP
# 
# NOTES
#
# - Command to extract certian type of lexc entries from Turkish side that dont yet exist on Uzbek lexc.
# - takes type name as a parameter.(Ex: noun, verb, abbr,..)
# - saves the resulting file with the name 'result'
TYPE=$1
# BIDIXFORMAT=$2 # <s n="np"/><s n="top"/>

# -------------------PART 1: Extracting from LEXC------------------#
printf "\n# -------------------PART 1: Extracting from LEXC------------------#\n\n"

# Extracting al lines that contain certain pattern in tur.lexc to new file:
grep " $TYPE \;" apertium-tur/apertium-tur.tur.lexc > tur.lexc
NUMOFLINES=$(wc -l < tur.lexc)
echo "Found $NUMOFLINES entries of type $TYPE from tur.lexc"

# Removing unnecessary part of the lexc to reveal a word a line & cleaning:
# Sorting the words and removing duplicates;
# Removing empty lines from file:
# Also replace "% "(space) with "<b/>";
# Also replace "%-"(dash) with "-";
# Also replace "%."(period) with "-";
awk -F":" '{print $1}' tur.lexc | sort -u | sed '/^[[:space:]]*$/d' > tmp
sed -e 's/\% /\<b\/\>/g' tmp | sed -e 's/\%-/-/g' | sed -e 's/\%././g' > tmp2
rm tmp
sort tmp2 > tur.lexc
rm tmp2
echo "Unnecessary part of the lexc format removed."
echo "File sorted."
echo "Empty lines removed."
echo "ʻ% ʻ has been replaced with ʻ<b/>ʻ."
NUMOFLINES=$(wc -l < tur.lexc)
echo "$NUMOFLINES entries left in tur.lexc after deduplication"

# -------------------PART 2: Removing entries that already exist in BIDIX from Extracted LEXC------------------#
printf "\n# -------------------PART 2: Removing entries that already exist in BIDIX from Extracted LEXC------------------#\n\n"

# Now, extracting entries with the given type from bidix:
# Extracting al lines that contain certain pattern to new file:
grep '<s n="np"/><s n="cog"/><s n="mf"/>' apertium-tur-uzb/apertium-tur-uzb.tur-uzb.dix > bidix
NUMOFLINES=$(wc -l < bidix)
echo "Found $NUMOFLINES entries of type $TYPE from bidix"

# Removing unnecessary part of the bidix to reveal a word a line & cleaning:
# Sorting the words and removing duplicates;
# Removing empty lines from file:
awk -F"<l>" '{print $2}' bidix | awk -F"<s n" '{print $1}' | sort -u | sed '/^[[:space:]]*$/d' > tmp
mv tmp bidix
echo "Unnecessary part of the bidix format removed."
echo "bidix file sorted."
echo "Empty lines removed."
NUMOFLINES=$(wc -l < bidix)
echo "$NUMOFLINES entries left in bidix after deduplication"

# Removing endries that already exist in bidix from tur.lexc:
comm -23 tur.lexc bidix > lexc
NUMOFLINES=$(wc -l < lexc)
echo "Found $NUMOFLINES entries that are not yet entered into bidix"


# -------------------PART 3: Forming BIDIX from resulting LEXC------------------#
printf "\n# -------------------PART 3: Forming BIDIX from resulting LEXC------------------#\n\n"

# Creating bidix format:
while IFS= read -r line; do
		line_uz=$line
# Trying to make Turkish words look more like Uzbek by replacing special chars:
		line_uz=${line_uz//"ş"/"sh"}
		line_uz=${line_uz//"Ş"/"Sh"}
		line_uz=${line_uz//"ı"/"i"}
		line_uz=${line_uz//"İ"/"I"}
		line_uz=${line_uz//"í"/"i"}
		line_uz=${line_uz//"Í"/"I"}
		line_uz=${line_uz//"ğ"/"gʻ"}
		line_uz=${line_uz//"Ğ"/"Gʻ"}
		line_uz=${line_uz//"ü"/"u"}
		line_uz=${line_uz//"Ü"/"U"}
		line_uz=${line_uz//"ç"/"ch"}
		line_uz=${line_uz//"Ç"/"Ch"}
		line_uz=${line_uz//"á"/"a"}
		line_uz=${line_uz//"Á"/"A"}
		line_uz=${line_uz//"ö"/"oʻ"}
		line_uz=${line_uz//"Ö"/"Oʻ"}
		line_uz=${line_uz//"ń"/"n"}
		line_uz=${line_uz//"Ń"/"N"}
		line_uz=${line_uz//"ū"/"u"}
		line_uz=${line_uz//"Ū"/"U"}
		line_uz=${line_uz//"â"/"a"}
		line_uz=${line_uz//"Â"/"A"}
		line_uz=${line_uz//"ó"/"o"}
		line_uz=${line_uz//"Ó"/"O"}
		line_uz=${line_uz//"é"/"e"}
		line_uz=${line_uz//"É"/"E"}
		line_uz=${line_uz//"ñ"/"ny"}
		line_uz=${line_uz//"Ñ"/"NY"}
		line_uz=${line_uz//"ę"/"e"}
		line_uz=${line_uz//"ę"/"e"}
		line_uz=${line_uz//"Ę"/"E"}
		line_uz=${line_uz//"ł"/"l"}
		line_uz=${line_uz//"Ł"/"L"}
		line_uz=${line_uz//"ã"/"a"}
		line_uz=${line_uz//"Ã"/"A"}
		line_uz=${line_uz//"w"/"w"}
		line_uz=${line_uz//"W"/"W"}
    # Manually insert necessary line here: (Could not automate below line.)
		#Ex: echo "<e>       <p><l>$line<s n=\"np\"/><s n=\"org\"/></l>	<r>$line_uz<s n=\"np\"/><s n=\"org\"/></r></p></e>" 
		echo "<e>       <p><l>$line<s n=\"np\"/><s n=\"cog\"/><s n=\"mf\"/></l>	<r>$line_uz<s n=\"np\"/><s n=\"cog\"/><s n=\"mf\"/></r></p></e>" 
done < lexc > lexc.bidix
echo "Words in a file turned to bidix format"

# Aligning the columns with whitespaces:
cat lexc.bidix |  tr '\t' '|' | column -t -s '|' > result
echo "Bidix format columns were aligned."

#Removing tmp files
rm bidix lexc.bidix tur.lexc

#Finish:
echo "Done! the resulting file name: result"


# -------------------PART 4: Trying to translate resulting LEXC using Google Translate API: ------------------#
printf "\n# -------------------PART 4: Trying to translate resulting LEXC using Google Translate API:------------------#\n\n"
read -p "Also try to translate using Google Translate API? (Y/N) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

#Run the python translator code:
python3 ../env/google-translater/mtranslate/translator-tur-uzb.py
echo "Translation saved in file: lexc.uz"

COUNTLEXC=$(wc -l < lexc)
COUNTLEXCUZ=$(wc -l < lexc.uz)
if [ $COUNTLEXC -ne $COUNTLEXCUZ ]
then
echo "Something went wrong with the translation here. lexc file contains $COUNTLEXC lines whereas lexc.uz has $COUNTLEXCUZ lines."
fi

# Creating bidix format:
COUNTLINE=1
while IFS= read -r line; do
		line_uz=$(sed -n "$COUNTLINE p" lexc.uz)
		let "COUNTLINE++"
		# Manually insert necessary line here: (Could not automate below line.)
		#Ex: echo "<e>       <p><l>$line<s n=\"np\"/><s n=\"top\"/></l>	<r>$line_uz<s n=\"np\"/><s n=\"top\"/></r></p></e>" 
		echo "<e>       <p><l>$line<s n=\"np\"/><s n=\"org\"/></l>	<r>$line_uz<s n=\"np\"/><s n=\"org\"/></r></p></e>" 
done < lexc > lexc.bidix.uz
echo "Words in lexc & lexc.uz files turned to bidix format"

# Aligning the uz columns with whitespaces:
cat lexc.bidix.uz |  tr '\t' '|' | column -t -s '|' > result.uz
echo "Bidix.uz format columns were aligned."

#Removing tmp files
rm lexc lexc.bidix.uz lexc.uz

#Finish:
echo "Done translation! the resulting file name: result.uz"


fi

