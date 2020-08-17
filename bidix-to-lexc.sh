#!/bin/bash
#
# NOTES
#
# - Command to transform right side of the bidix entries to lexc ones. 
# - takes filename and lexical tag as parameters.
# - saves the resulting file as $FILE.lexc
FILE=$1
LEXC=$2


# -------------------PART 1: Extracting from given BIDIX file------------------#
printf "\n# -------------------PART 1: Extracting from given BIDIX file------------------#\n\n"


# Removing empty lines from file:
sed -i '/^[[:space:]]*$/d' $FILE
echo "Empty lines removed."

# Removing unnecessary part of the bidix to reveal a word per line:
awk -F"<r>" '{print $2}' $FILE | awk -F"<s" '{print $1}'> $FILE.words
echo "Unnecessary part of the bidix format removed."

# Sorting the words and removing duplicates;
# Also replace "<b/>"(space) with "% ";
# Also replace "-"(dash) with "%-";
# Also replace "."(dash) with "%.";
sort -u $FILE.words| sed -e 's/<b\/>/\% /g' | sed -e 's/-/\%-/g' | sed -e 's/\./\%./g'> $FILE.sorted
sort $FILE.sorted > tmp
mv tmp  $FILE.sorted
echo "File sorted."
echo "ʻ<b/>ʻ has been replaced with ʻ% ʻ."
NUMOFLINES=$(wc -l < $FILE.sorted)
echo "There are $NUMOFLINES entries in $FILE.sorted"

# -------------------PART 2: Removing entries that already exist in uzb.LEXC from Extracted BIDIX------------------#
printf "\n# -------------------PART 2: Removing entries that already exist in uzb.LEXC from Extracted BIDIX------------------#\n\n"


# Extracting al lines that contain certain lexc pattern in uzb.lexc to new file:
grep " $LEXC \; \!" apertium-uzb/apertium-uzb.uzb.lexc > uzb.lexc
NUMOFLINES=$(wc -l < uzb.lexc)
echo "Found $NUMOFLINES entries of type $LEXC from uzb.lexc"

# Removing unnecessary part of the lexc to reveal a word a line & cleaning:
# Sorting the words and removing duplicates;
# Removing empty lines from file:
awk -F":" '{print $1}' uzb.lexc | sort -u | sed '/^[[:space:]]*$/d' > tmp
mv tmp uzb.lexc
echo "Unnecessary part of the lexc format removed."
echo "resulting uzb.lexc File sorted."
echo "Empty lines removed."
NUMOFLINES=$(wc -l < uzb.lexc)
echo "$NUMOFLINES entries left in uzb.lexc after deduplication"

#Now, we have $FILE.sorted file with new entries and we have to remove all entries that already exist in uzb.lexc file:
comm -23 $FILE.sorted uzb.lexc > $FILE.clean
NUMOFLINES=$(wc -l < $FILE.clean)
echo "Found $NUMOFLINES entries that are not yet entered into bidix"

# -------------------PART 3: Forming LEXC from resulting BIDIX------------------#
printf "\n# -------------------PART 3: Forming LEXC from resulting BIDIX------------------#\n\n"

# Creating bidix format:
while IFS= read -r line; do
    echo "$line:$line  $LEXC ; ! \"\" ! El++"
done < $FILE.clean > $FILE.lexc
echo "Words in a file turned to lexc format(in  $FILE.lexc)"
NUMOFLINES=$(wc -l < $FILE.lexc)
echo "There are $NUMOFLINES entries left in $FILE.lexc"

#Finish:
echo "Done! the resulting file is: $FILE.lexc"


