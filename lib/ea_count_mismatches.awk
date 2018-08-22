function count_mismatches(str_a, str_b) {
#        ----------------
#
# Compare two strings and count the difference between them.
#
# Both strings should be of the same length
#
	str_a = tolower(str_a)
	str_b = tolower(str_b)
	n = length(str_a)
	_diff = 0
	if (n == length(str_b)) {
		split(str_a, a, "")
		split(str_b, b, "")
		for (i = 1; i <= n; i++) {
			if (a[i] != b[i]) {
				_diff++
			}
		}
		return _diff
	} else {
		print "error: " str_a " and " str_b " are not of the same length"
		#exit 1 # false
	}
}
