package org.uqbar.domain

import java.math.BigDecimal
import java.util.List
import org.uqbar.domain.exceptions.UserException
import redis.clients.jedis.Jedis
import redis.clients.jedis.JedisPool
import redis.clients.jedis.JedisPoolConfig
import redis.clients.jedis.exceptions.JedisConnectionException

class ConversorFactory {

	static JedisPool jedisPool = new JedisPool(new JedisPoolConfig, Constants.LOCALHOST)

	def static List<Conversion> generarConversiones() {
		val conversiones = newArrayList
		conversiones.add(
			new Conversion => [
				cotizacionMoneda = applyOnJedis(traerValorDeLista(Constants.DOLAR, 1))
				descripcion = "Dólar actual (u$s)"
			]
		)
		conversiones.add(
			new Conversion => [
				cotizacionMoneda = applyOnJedis(traerValor(Constants.EURO))
				descripcion = "Euro (€)"
			]
		)
		conversiones.add(
			new Conversion => [
				cotizacionMoneda = applyOnJedis(traerValorDeLista(Constants.DOLAR, 0))
				descripcion = "Dólar previo (u$s)"
			]
		)
		conversiones.add(
			new Conversion => [
				cotizacionMoneda = applyOnJedis(traerValor(Constants.REAL))
				descripcion = "Real (R$)"
			]
		)
		conversiones
	}

	private static def applyOnJedis((Jedis)=>String aBlock) {
		var Jedis jedis
		try {
			jedis = jedisPool.resource
			val value = aBlock.apply(jedis)
			if (value === null) {
				throw new UserException("No hay datos de las monedas solicitadas")
			}
			val returnValue = new BigDecimal(value)
			jedis.close()
			returnValue
		} catch (JedisConnectionException e) {
			throw new UserException("Error de conexión a Redis")
		} finally {
			if (jedis !== null)
				jedis.close()
		}
	}

	private static def traerValorDeLista(String key, int position) {
		return [Jedis jedis|jedis.lindex(key, position)]
	}

	private static def traerValor(String key) {
		return [Jedis jedis|jedis.get(key)]
	}
}
