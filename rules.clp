(defrule advertenciaStock
   ?line <- (line-item (orderNumber ?oNum) (productId ?pid) (quantity ?q) (processed FALSE))
   (product (productId ?pid) (model ?m) (stock ?s&:(< ?s ?q)))
=>
   (printout t "Advertencia: No hay suficiente stock para el producto " ?pid
             " (modelo: " ?m "). Solicitado: " ?q ", Disponible: " ?s "." crlf)
   (modify ?line (processed TRUE))
)

(defrule esMayoristaDescuento
   (customer (customerId ?cid) (name ?nombre ?apellido))
   (order (orderNumber ?oNum) (customerId ?cid))
   (line-item (orderNumber ?oNum) (productId ?pid) (quantity ?q&:(> ?q 10)))
   =>
   (printout t "Mayorista. El cliente " ?nombre " " ?apellido " es mayorista por comprar más de 10 unidades del producto " ?pid crlf)
   (printout t "Mayorista. Se aplicó un descuento del 15% a la orden " ?oNum crlf)
   )

(defrule clienteNoCompra
   (customer (customerId ?cid) (name $?nombre))
   (not (order (customerId ?cid)))
=>
   (printout t "No compra. El cliente " (implode$ ?nombre) " no ha comprado nada." crlf)
)

; Reglas de las 20 pedidas

(defrule descuentoPagoEfectivo
  (order (orderNumber ?num) (paymentMethod "cash") (customerId ?cid))
  (customer (customerId ?cid) (name $?nombre))
  =>
  (bind ?nombreCompleto (implode$ ?nombre))
  (printout t "1. Se aplicó un descuento de $100 a la orden " ?num
              " del cliente " ?nombreCompleto " por pagar en efectivo." crlf)
)

(defrule descuentoMayorMil
  (order (orderNumber ?num) (customerId ?cid))
  (line-item (orderNumber ?num) (productId ?pid) (quantity ?q))
  (product (productId ?pid) (price ?p))
  (test (> (* ?p ?q) 1000))
  (customer (customerId ?cid) (name $?nombre))
=>
  (printout t "2." (implode$ ?nombre)
            " recibe un descuento de 10% porque su producto " ?pid " supera los $1000 ("
            (* ?p ?q) " MXN)." crlf)
)

(defrule descuentoMismaMarca
  (order (orderNumber ?num) (customerId ?cid))
  (line-item (orderNumber ?num) (productId ?pid1))
  (product (productId ?pid1) (brand ?marca))
  
  (line-item (orderNumber ?num) (productId ?pid2))
  (product (productId ?pid2) (brand ?marca) (category ?cat2))
  
  (test (neq ?pid1 ?pid2))  ;; Asegura que son productos distintos
  (customer (customerId ?cid) (name $?nombre))
=>
  (printout t "3. El cliente " (implode$ ?nombre)
            " recibió un descuento en el accesorio " ?pid2
            " por comprar un producto de la misma marca (" ?marca ")." crlf)
)

(defrule msiSmartphoneAppleVisa
   (order (orderNumber ?oNum) (customerId ?cid) (paymentMethod "card"))
   (customer (customerId ?cid) (cardId ?cardId))
   (card (cardID ?cardId) (group "visa") (type "credit"))
   (line-item (orderNumber ?oNum) (productId ?pid))
   (product (productId ?pid) (brand apple) (category "smartphone"))
=>
   (printout t "4. La orden " ?oNum " del cliente con ID " ?cid " califica para meses sin intereses por comprar un smartphone Apple con tarjeta VISA." crlf)
)

(defrule msiComputerHpMastercard
   (order (orderNumber ?oNum) (customerId ?cid) (paymentMethod "card"))
   (customer (customerId ?cid) (cardId ?cardId))
   (card (cardID ?cardId) (group "mastercard") (type "credit"))
   (line-item (orderNumber ?oNum) (productId ?pid))
   (product (productId ?pid) (brand hp) (category "computer"))
=>
   (printout t "5. La orden " ?oNum " del cliente con ID " ?cid " califica para meses sin intereses por comprar una computadora HP con tarjeta MASTERCARD." crlf)
)

(defrule descuentoMismoColor
  (order (orderNumber ?num) (customerId ?cid))
  (customer (customerId ?cid) (name $?nombre))

  ;; Dos productos distintos en la misma orden
  (line-item (orderNumber ?num) (productId ?pid1))
  (line-item (orderNumber ?num) (productId ?pid2&:(neq ?pid1 ?pid2)))

  ?prod1 <- (product (productId ?pid1) (color ?color))
  ?prod2 <- (product (productId ?pid2) (color ?color))

   (test (neq ?pid1 ?pid2))  ;; Asegura que son productos distintos

  =>
  (bind ?nombreCompleto (implode$ ?nombre))
  (printout t "6. Se aplicó un descuento de $100 a la orden " ?num
              " del cliente " ?nombreCompleto
              " por incluir productos del mismo color (" ?color ")." crlf)
)

(defrule descuentoAccesorioMitadPrecio
  ?li1 <- (line-item (orderNumber ?num) (productId ?pid) (quantity ?q1&:(>= ?q1 2)))
  (product (productId ?pid) (category ?cat&:(or (eq ?cat "mouse")
                                                (eq ?cat "keyboard")
                                                (eq ?cat "case")
                                                (eq ?cat "cable")
                                                (eq ?cat "headphones"))) 
           (price ?precio))
  (order (orderNumber ?num) (customerId ?cid))
  (customer (customerId ?cid) (name $?nombre))
  =>
  (bind ?nombreCompleto (implode$ ?nombre))
  (bind ?descuento (/ ?precio 2))
  (printout t "7. Cliente: " ?nombreCompleto " recibe un descuento de $" ?descuento
              " en uno de los accesorios (id: " ?pid ") por promoción de 2x1 a mitad de precio." crlf)
)

(defrule sugerirTecladoSiMouse
  (order (orderNumber ?num) (customerId ?cid))
  (customer (customerId ?cid) (name $?nombre))

  (line-item (orderNumber ?num) (productId ?pidMouse))
  (product (productId ?pidMouse) (category "mouse"))

  (not
    (and
      (line-item (orderNumber ?num) (productId ?pidKey))
      (product (productId ?pidKey) (category "keyboard"))
    )
  )

  =>
  (printout t "8. Sugerencia: el cliente " (implode$ ?nombre)
            " compró un mouse pero no un teclado. Podría interesarle un teclado para complementar su compra." crlf)
)

(defrule sugerirMouseSiTeclado
  (order (orderNumber ?num) (customerId ?cid))
  (customer (customerId ?cid) (name $?nombre))

  (line-item (orderNumber ?num) (productId ?pidKey))
  (product (productId ?pidKey) (category "keyboard"))

  (not
    (and
      (line-item (orderNumber ?num) (productId ?pidMouse))
      (product (productId ?pidMouse) (category "mouse"))
    )
  )

  =>
  (printout t "9. Sugerencia: el cliente " (implode$ ?nombre)
            " compró un teclado pero no un mouse. Podría interesarle un mouse para complementar su compra." crlf)
)

(defrule sugerirAudifonosSiSmartphone
  (order (orderNumber ?num) (customerId ?cid))
  (customer (customerId ?cid) (name $?nombre))

  (line-item (orderNumber ?num) (productId ?pidSmart))
  (product (productId ?pidSmart) (category "smartphone"))

  (not
    (and
      (line-item (orderNumber ?num) (productId ?pidAud))
      (product (productId ?pidAud) (category "headphones"))
    )
  )

  =>
  (printout t "10. Sugerencia: el cliente " (implode$ ?nombre)
            " compró un smartphone pero no audífonos. Podría interesarle adquirir unos audífonos compatibles." crlf)
)

(defrule sugerirAudifonosSiSmartphone
  (order (orderNumber ?num) (customerId ?cid))
  (customer (customerId ?cid) (name $?nombre))

  (line-item (orderNumber ?num) (productId ?pidSmart))
  (product (productId ?pidSmart) (category "smartphone"))

  (not
    (and
      (line-item (orderNumber ?num) (productId ?pidAud))
      (product (productId ?pidAud) (category "case"))
    )
  )

  =>
  (printout t "11. Sugerencia: el cliente " (implode$ ?nombre)
            " compró un smartphone pero no una funda. Podría añadir una funda protectora." crlf)
)

(defrule ofertaSamsung
  (order (orderNumber ?num) (customerId ?cid))
  (line-item (orderNumber ?num) (productId ?pid))
  (product (productId ?pid) (brand samsung) (category "smartphone"))
  (customer (customerId ?cid) (name $?nombre))
  =>
  (printout t "12. El cliente " (implode$ ?nombre) " ha comprado un smartphone Samsung. Se le regalan 150 pesos de saldo." crlf)
)

(defrule msiAppleCredito
   (order (orderNumber ?num) (customerId ?cid) (paymentMethod "card"))
   (customer (customerId ?cid) (cardId ?cardId))
   (card (cardID ?cardId) (type "credit"))
   (line-item (orderNumber ?num) (productId ?pid))
   (product (productId ?pid) (brand apple))
=>
   (printout t "13. La orden " ?num " del cliente " ?cid
              " califica para meses sin intereses por comprar un producto Apple con tarjeta de crédito." crlf)
)

(defrule promocionMotorolaDebitoMC
   (order (orderNumber ?num) (customerId ?cid) (paymentMethod "card"))
   (customer (customerId ?cid) (cardId ?cardId))
   (card (cardID ?cardId) (type "debit") (group "mastercard"))
   (line-item (orderNumber ?num) (productId ?pid))
   (product (productId ?pid) (brand motorola))
=>
   (printout t "14. La orden " ?num " del cliente " ?cid
              " califica para una promoción especial por comprar un producto Motorola con tarjeta de débito Mastercard." crlf)
)

(defrule descuentoAccesorioBanamex
  (order (orderNumber ?num) (customerId ?cid) (paymentMethod "card"))
  (customer (customerId ?cid) (cardId ?cardId))
  (card (cardID ?cardId) (bank "banamex") (type "credit"))
  (line-item (orderNumber ?num) (productId ?pid))
  (product (productId ?pid) 
           (category ?cat&:(or (eq ?cat "mouse") 
                               (eq ?cat "keyboard") 
                               (eq ?cat "headphones")
                               (eq ?cat "charger")
                               (eq ?cat "case")))
           (price ?p))
  =>
  (bind ?nuevoPrecio (/ ?p 2))
  (printout t "15. El cliente " ?cid " recibe un 50% de descuento en el accesorio " ?pid
              " por pagar con tarjeta de crédito Banamex. Nuevo precio: $" ?nuevoPrecio crlf)
)

(defrule descuentoSmartphoneEfectivo
  (order (orderNumber ?num) (customerId ?cid) (paymentMethod "cash"))
  (line-item (orderNumber ?num) (productId ?pid))
  (product (productId ?pid) (category "smartphone") (price ?p))
  =>
  (bind ?descuento (* ?p 0.10))
  (bind ?nuevoPrecio (- ?p ?descuento))
  (printout t "16. El cliente " ?cid 
              " recibe un 10% de descuento en el smartphone " ?pid
              " por pagar en efectivo. Precio final: $" ?nuevoPrecio crlf)
)

(defrule valesAmex
  (order (orderNumber ?num) (customerId ?cid) (paymentMethod "card"))
  (customer (customerId ?cid) (cardId ?cardId))
  (card (cardID ?cardId) (group "american express"))
  =>
  (printout t "17. La orden " ?num " califica para $100 MXN en vales por pagar con tarjeta American Express." crlf)
)

(defrule valesBanregio
  (order (orderNumber ?num) (customerId ?cid) (paymentMethod "card"))
  (customer (customerId ?cid) (cardId ?cardId))
  (card (cardID ?cardId) (bank "banregio"))
  =>
  (printout t "18. La orden " ?num " califica para $100 MXN en vales por pagar con tarjeta Banregio." crlf)
)

(defrule descuentoAudifonos
  (order (orderNumber ?num) (customerId ?cid))
  (line-item (orderNumber ?num) (productId ?pid))
  (product (productId ?pid) (category "headphones") (price ?p))
  =>
  (printout t "19. La orden " ?num " califica para un 10% de descuento en audífonos." crlf)
)

(defrule descuento-charger-cable
  (order (orderNumber ?num) (customerId ?cid))
  (line-item (orderNumber ?num) (productId ?pid1))
  (product (productId ?pid1) (category "charger"))
  (line-item (orderNumber ?num) (productId ?pid2))
  (product (productId ?pid2) (category "cable"))
  =>
  (printout t "20. La orden " ?num " califica para un 15% de descuento por comprar cargador y cable." crlf)
)


(defrule actualizarStock
   ?line <- (line-item (orderNumber ?num) (productId ?pid) (quantity ?q) (processed FALSE))
   ?prod <- (product (productId ?pid) (category ?c) (model ?m) (stock ?s&:(>= ?s ?q)))
   =>
   (bind ?nuevoStock (- ?s ?q))
   (modify ?prod (stock ?nuevoStock))
   (modify ?line (processed TRUE)) 
   (printout t "Se actualizó el stock del " ?c " modelo " ?m ": ahora hay " ?nuevoStock " unidades." crlf)
   )

(defrule agotado
   (product (productId ?pid) (model ?m) (stock 0))
=>
   (printout t "El producto " ?pid " (modelo: " ?m ") se ha agotado. Se requiere reabastecimiento." crlf)
)