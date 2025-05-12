(deftemplate customer
  (slot customerId)
  (multislot name)
  (multislot address)
  (slot phone)
  (slot cardId)
) 

(deftemplate order
  (slot orderNumber)
  (slot customerId)
  (slot paymentMethod)
)

(deftemplate line-item
  (slot orderNumber)
  (slot productId)
  (slot quantity (default 1))
  (slot processed (default FALSE))
)

(deftemplate product
  (slot productId)
  (slot category)
  (slot brand)
  (slot model)
  (slot color)
  (slot price)
  (slot stock)
)

(deftemplate card
  (slot cardID)
  (slot number)
  (slot bank)
  (slot expirationDate)
  (slot type)
  (slot group)
)
