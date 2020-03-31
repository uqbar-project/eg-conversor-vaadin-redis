package org.uqbar.domain

import java.math.BigDecimal
import org.eclipse.xtend.lib.annotations.Accessors

import static extension org.uqbar.domain.NumberUtil.*

@Accessors
class Conversion {
	BigDecimal cotizacionMoneda
	String descripcion
	BigDecimal valorConvertido
	
	def void convertir(BigDecimal unValor) {
		valorConvertido = unValor / cotizacionMoneda
	}
	
	def getCotizacionDeMoneda() {
		cotizacionMoneda.format
	}
	
	def getValorActual() {
		valorConvertido.format
	}
}
