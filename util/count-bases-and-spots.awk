#!/usr/bin/awk -f

# Column 12: sample ids
# Column 15: spots
# Column 16: bases

BEGIN{FS="\t"}

$8 == "RUN" && ! ($1 in runids) {
    spots += $15
    bases += $16
    total++
    runids[$1]++
}
END{print total, spots, bases}
