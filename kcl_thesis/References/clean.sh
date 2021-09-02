#get rid of month and other things in the .bib so it does not appear in the bloody references 

grep -v ^mon library.bib > test.bib
grep -v ^institution test.bib > test2.bib
grep -v ^url test2.bib > test3.bib
grep -v ^abstract test3.bib > test4.bib
grep -v ^file test4.bib > test5.bib
grep -v ^issn test5.bib > test6.bib
grep -v ^doi test6.bib > test7.bib
grep -v ^pmid test7.bib > test8.bib
grep -v ^annote test8.bib > test9.bib
grep -v ^abstract test9.bib > test10.bib
grep -v ^keywords test10.bib > test11.bib
grep -v ^mendeley-tags test11.bib > test12.bib
cp test12.bib ref.bib
rm test*

sed -i 's/Proc. Natl. Acad. Sci. U. S. A./Proc. Natl. Acad. Sci./g' ref.bib
sed -i 's/Proc. Natl. Acad. Sci. U.S.A./Proc. Natl. Acad. Sci./g' ref.bib
sed -i 's/J Phys Chem B/J. Phys. Chem. B/g' ref.bib
sed -i 's/Science (80-. )/Science/g' ref.bib


