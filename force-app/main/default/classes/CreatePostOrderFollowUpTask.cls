public With Sharing class CreatePostOrderFollowUpTask implements Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public String query; 
    public Integer recordsProcessed = 0;
        
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //getting orders created today 
        query = 'SELECT ID, Name, ContactId__c, CustomInkOrderAmount__c, CustomInkOrderNumber__c, OwnerId, DeliveryDate__c FROM Order WHERE CreatedDate = TODAY'; 
        System.debug('Query: '+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Order> scope){
       //add items to a set deduped on contact id
        Map<Id,Order> mapOrder = new Map<Id,Order>();
        for(Order item: scope){
            mapOrder.put(item.Id,item); 
        }
    system.debug(scope+' '+scope); 

    //update map with contact orders with the same delivery date 
    //break this out to separate class in refactor 
    Map<Id,List<Order>> orderMap = GetRelatedOrders.getOrderMap(scope, mapOrder); 
    system.debug('orderMap: '+orderMap); 

    //gets the highest order amount for the list at each contact record 
    Set<Order> ordersForTasks = new Set<Order>(); 
        for(Order ord: scope){
            system.debug('current order: '+ord); 
            system.debug('orderMap.get(ord.Id: '+orderMap.get(ord.ContactId__c));
            if(orderMap.get(ord.ContactId__c) != null){
                List<Order> orderForHighest = orderMap.get(ord.ContactId__c); 
                ordersForTasks.add(GetRelatedOrders.getHighestOrderAmount(ord,orderForHighest)); 
                system.debug(ordersForTasks); 
                }
            }
    //calculate due date 
    //check for kitted orders 
    //testing CLI 
    
    //loop over orders for tasks and create tasks 
    List<Task> taskList = new List<Task>(); 
    for(Order ord: ordersForTasks){
        Task postOrderTask = new Task(
            OwnerId = ord.OwnerId,
            Priority = 'High',
            Status = 'Open',
            Subject = 'Post Order Follow-Up Task',
            WhatId = ord.Id,
            WhoId = ord.ContactId__c

            );
            taskList.add(postOrderTask);
            system.debug(taskList); 
            recordsProcessed +=1;

        }

    insert taskList; 
    }
    

    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed!');
        
        }
    
}