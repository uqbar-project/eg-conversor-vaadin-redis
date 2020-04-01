# Conversor a Redis (versión con Vaadin)

Ejemplo de conversor de moneda utilizando a Redis como cache para almacenar las cotizaciones. El mismo utiliza el plugin de Jedis para conectarse con la base de datos. Podés seguir la guía de persistencia en [este link](https://docs.google.com/document/d/1eTmmFrADzvp2H9Vg88_ChqRc61U0tNx-FXntkmzmvlE/edit?usp=sharing)

# El ejemplo

![demo](./video/demo.gif)

El ejemplo está escrito en Vaadin, y muestra una pantalla muy simple, donde

- inicialmente cargamos las cotizaciones del día de hoy para el dólar, euro y real, y la cotización del día anterior del dólar
- luego permitimos ingresar un monto numérico, equivalente al valor en pesos
- al presionar el botón convertir, se visualiza una lista de las conversiones correspondientes a cada cotización

# REDIS

Es una Base de datos del tipo Key-Value open source. Simplemente guardan tuplas que contienen una clave y su valor. Cuándo se quiere recuperar un dato, simplemente se busca por su clave y se recupera el mismo. Los datos son BLOB (Binary Large Object), por lo tanto son opacos (el motor no saben que es), dejando esta responsabilidad en el dominio de la aplicación

## Instalando Redis

Para ponernos en contexto les comentamos que Redis está escrito en lenguaje ANSI C y funciona en la mayoría de los sistemas POSIX como Linux, * BSD, OS X sin dependencias externas. Para poder correr el ejemplo, tenemos que previamente tener instalado redis. Para esto tenemos que ir a la [página oficial de redis](https://redis.io/) y bajar la última versión. En el ejemplo asumiremos que la última versión es la 5.0.7, pero adaptala a la que vayas a bajar desde [este link](http://download.redis.io/releases/redis-5.0.7.tar.gz).
Una vez terminado de descargar, realizamos los siguientes pasos:
- Descomprimimos el archivo bajado y pasamos a la carpeta

```bash
tar xzvf redis-5.0.7.tar.gz
cd redis-5.0.7
```

- Ahora procedemos a compilar los binarios de la base de datos de la siguiente manera

```bash
make
```
- Luego de forma opcional podemos correr los scripts de testeo para ver si la compilación fué exitosa. 

```bash
make test
```

> Si te aparece un error similar a "You need tcl 8.5 or newer in order to run the Redis test" instalalo siguiendo los pasos de [esta pregunta de Stack Overflow](https://askubuntu.com/questions/58869/how-to-sucessfully-install-redis-server-tclsh8-5-not-found-error)

Los principales binarios a utilizar son **redis-server** y **redis-cli**, ambos **se encuentran en el directorio src**. Para levantar una instancia de la base de datos solamente tenemos que ejecutar la siguiente línea

```bash
./src/redis-server
```

Y para levantar un cliente nada más tenemos que hacer 

```bash
./src/redis-cli
```

## Principales tipos de datos

Si bien los datos para redis son *opacos*, nos permite definir una serie de estructuras con als cuales opera sobre el dato guardado. 

### String
Son Binary Safe, lo cual significa que soporta cualquier cadena binaria. Tiene un tamaño máximo de 512 Megabytes.

### List
Simplemente son listas de strings. Tienen la idea de pila, con lo cual soportan acciones de push y pop tanto a derecha como a izquierda. El número máximo de elementos en un conjunto es 232 - 1 (4294967295, más de 4 mil millones de elementos por conjunto)

### Sets
Al igual que los tipos de datos List manejan una colección de Strings pero en este caso no tienen orden con lo cual no le pertenece el mismo set de instrucciones.

### Hashes
Permite guardar en un valor una colección de pares clave valor.

### HiperLoglog

Este tipo de dato es una estructura de datos probabilísticos utilizada para conteos. Por lo general, contar elementos únicos requiere utilizar una cantidad de memoria proporcional al número de elementos que desea contar, porque debe recordar los elementos que ya ha visto en el pasado para evitar contarlos varias veces. Sin embargo, existe un conjunto de algoritmos sacrifican precisión por menos memoria y performance: fEn el caso de la implementación de Redis es inferior al 1%.

### Valores Geoespaciales
Permite almacenar una tupla con los valores de latitud y longitud permitiendo realizar operaciones básicas como calcular distancias. 

## Principales operaciones

### Con strings

```
APPEND key value               # Concatena al final un valor.
SET key value                  # Setea un valor en una clave.
SETNX key value                # Setea un valor en una clave si no existe.
SETRANGE key offset value      # Sobre-escribe una parte de un string.
STRLEN key                     # Largo de un string.
GET key                        # Obtiene el valor para una clave.
GETRANGE key value             # Obtiene un substring del valor para una clave
INCR key                       # Incrementa el valor de un contador.
DECR key                       # Decrementa el valor de un contador.
DEL key                        # Borra una clave.
EXPIRE key 120                 # Setea un Time to live de 120 segundos para la clave.
TTL key                        # Retorna el tiempo en segundos que queda de vida para la clave.
```

### Con listas

```
RPUSH key value [value ...]           # Inserta un nuevo valor al final de la lista.
LPUSH key value [value ...]           # Inserta un nuevo valor al principio de la lista.
LRANGE key start stop                 # Devuelve un subset de la lista.
LINDEX key index                      # Obtenemos un elemento de la lista por su índice.
LINSERT key BEFORE|AFTER pivot value  # Inserta un elemento antes o después de otro en la lista.
LLEN key                              # Devuelve el largo de la lista.
LPOP key                              # Elimina el primer elemento de la lista y lo devuelve.
LSET key index value                  # Setea un valor en una determinada posición de la lista.
LTRIM key start stop                  # Realiza un trim a la lista.
RPOP key                              # Elimina el último elemento de la lista y lo devuelve.
```
