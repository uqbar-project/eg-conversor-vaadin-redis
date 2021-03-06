package org.uqbar

import com.vaadin.annotations.Theme
import com.vaadin.annotations.VaadinServletConfiguration
import com.vaadin.server.VaadinRequest
import com.vaadin.server.VaadinServlet
import com.vaadin.ui.Button
import com.vaadin.ui.Grid
import com.vaadin.ui.Label
import com.vaadin.ui.UI
import com.vaadin.ui.VerticalLayout
import java.math.BigDecimal
import javax.servlet.annotation.WebServlet
import org.uqbar.domain.Conversion
import org.uqbar.domain.ConversorFactory
import org.vaadin.ui.NumberField

/** 
 * This UI is the application entry point. A UI may either represent a browser window 
 * (or tab) or some part of an HTML page where a Vaadin application is embedded.
 * <p>
 * The UI is initialized using {@link #init(VaadinRequest)}. This method is intended to be 
 * overridden to add component to the user interface and initialize non-component functionality.
 */
@Theme("mytheme")
class ConversorUI extends UI {
	override protected void init(VaadinRequest vaadinRequest) {
		val conversiones = ConversorFactory.generarConversiones
		
		val VerticalLayout layout = new VerticalLayout()
		
		val divTitulo = new Label("Conversor Redis") => [
			height = "15"
		]
		
		val txtMonto = new NumberField() => [
			caption = "Monto en pesos"
			placeholder = "Monto a convertir en $$$"
			width = "300"
			decimalAllowed = true
			decimalPrecision = 2
			negativeAllowed = false
		]
		
		val grillaCotizaciones = new Grid<Conversion>(Conversion) => [
			items = conversiones
			setColumns("descripcion", "cotizacionDeMoneda", "valorActual")
		]

		val Button btnConvertir = new Button("Convertir")
		btnConvertir.addClickListener([ e |
			val monto = if (txtMonto.value ?: "" === "") "0" else txtMonto.value
			conversiones.forEach [ conversion | conversion.convertir(new BigDecimal(monto)) ]
			grillaCotizaciones.getDataProvider().refreshAll
		])
			
		layout.addComponents(divTitulo, txtMonto, btnConvertir, grillaCotizaciones)
		setContent(layout)
	}

	@WebServlet(urlPatterns="/*", name="ConversorUIServlet", asyncSupported=true) @VaadinServletConfiguration(ui=ConversorUI, productionMode=false)
	static class ConversorUIServlet extends VaadinServlet {
	}
}
