function count_mismatches(str_a, str_b) {
#        ----------------
#
# Compare two strings and count the difference between them.
#
# Both strings should be of the same length
#
	str_a = tolower(str_a)
	str_b = tolower(str_b)
	n1 = length(str_a)
	n2 = length(str_b)
	_diff = 0
	if (str_a == NA || str_b == NA) {
		return length_if_not_na(str_a) + length_if_not_na(str_b)
	}
	n = n1 > n2 ? n1 : n2
	split(str_a, a, "")
	split(str_b, b, "")
	for (i = 1; i <= n; i++) {
		if (a[i] != b[i]) {
			_diff++
		}
	}
	return _diff
}
