package org.uqbar.domain

import java.math.BigDecimal
import java.text.DecimalFormat

class NumberUtil {
	
	def static format(BigDecimal valor) {
		if (valor === null) return ""
		new DecimalFormat("#,###,##0.00").format(valor).replace(".", ",")
	}
}