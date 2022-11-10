public with sharing class GetRelatedOrders {
    //gets highest order 
    public static Order getHighestOrderAmount(Order ord, List<Order> orderForHighest) {
        Order highestOrder = ord; 
        for(Order subOrder: orderForHighest){
            if(subOrder.CustomInkOrderAmount__c > ord.CustomInkOrderAmount__c && subOrder.DeliveryDate__c == ord.DeliveryDate__c){
                highestOrder = subOrder; 
                System.debug('highest order is: '+highestOrder); 
            }
        }
        return highestOrder; 
    }

    //Get items with same delivery date
    public static Map <Id,List<Order>> getOrderMap(List<Order>scope,Map<Id,Order>mapOrder){
        Map<Id,List<Order>> orderMap = new Map<Id,List<Order>>(); 
        for(Order ord: scope){
            for(Id mapItem: mapOrder.keySet()){
                List<Order> sameDate = new List<Order>(); 
                if(ord.DeliveryDate__c == mapOrder.get(mapItem).DeliveryDate__c && ord.ContactId__c == mapOrder.get(mapItem).ContactId__c){
                    if(orderMap.get(ord.ContactId__c) != null){
                    List<Order> sublist = orderMap.get(ord.ContactId__c);
                    sublist.add(ord); 
                    }
                    else{
                    sameDate.add(ord); 
                    orderMap.put(ord.ContactId__c,sameDate); 
                    system.debug('orderMap size is '+orderMap.size()); 
                    }
                }
            }
        }
        return orderMap; 
    }

}
