public class PatentObjectQueuable implements Queueable {
    
    public Id patentId;
    public List<Id> patentIds;
    public Set<Id> managerIds=new Set<Id>();
    public Boolean processingDone =false;
    
    public PatentObjectQueuable(List<Id> patentIds){
        this.patentIds= patentIds;
    }
    
    public PatentObjectQueuable(Id patentId,Set<Id> managerIds){
        this.patentId = patentId;
        this.managerIds =managerIds;
    }
    
    public PatentObjectQueuable(){
        
    }
    
    public Set<Id> patenttoShareUsers1(Set<Id> setInventors){
        Set<Id> personManagerIds=new Set<Id>();
        for(Inventor__c inventor:[SELECT First_Name__c,Id,Manager_Name__c
                                               FROM Inventor__c WHERE Id IN : setInventors])
        {
            if(inventor.Manager_Name__c != null){
               personManagerIds.add(inventor.Manager_Name__c);
            }

            
        }
        System.debug(personManagerIds);
        return personManagerIds;
    }
    
    public Set<Id> patenttoShareUsers(Set<Id> setInventors){
        Set<Id> personManagerIds=new Set<Id>();
        for(Inventor__c inventor:[SELECT First_Name__c,Id,Manager_Name__c, 
                                               FROM Inventor__c WHERE Id IN : setInventors])
        {
            if(inventor.Manager_Name__c != null){
               personManagerIds.add(inventor.Manager_Name__c);
            }
        }
        
        System.debug(personManagerIds);
        if(!personManagerIds.isEmpty()){
            Set<Id> managers=new Set<Id>();
            do {
                PatentObjectQueuable pq=new PatentObjectQueuable();
                managers=pq.patenttoShareUsers1(personManagerIds);
                Boolean hasNewData=false;
                for(Id currentId:managers){
                    if(!personManagerIds.contains(currentId)){
                        hasNewData =true;
                    }
                }
                
                if(!hasNewData){
                    managers.clear();
                }
                personManagerIds.addAll(managers);
                
                
            } while (!managers.isEmpty());
        }
        return personManagerIds;
    }
    
    public void execute(QueueableContext context) {            
        
        Set<Id> setPatentUsers=new Set<Id>();
        patentId =patentIds[0];
        for(Patent__c patent:[Select Temporary_Firm__c,Annuity_Payer__c,Business_Contact__c,Docketing_Contact__c,
                                           Symphony_IPM_Family_Attorney__c,First_Named_Inventor__c,Foreign_Agent__c,Inventor__c,Paralegal__c,
                                           Portfolio_Manager__c,Primary_Inventor__c,Prosecuting_Counsel__c from Patent__c Where Id = : patentId])
        {
            if(patent.Temporary_Firm__c != null){
                setPatentUsers.add(patent.Temporary_Firm__c);        
            }
            
            if(patent.Annuity_Payer__c != null){
                setPatentUsers.add(patent.Annuity_Payer__c);        
            }
            
            if(patent.Business_Contact__c != null){
                setPatentUsers.add(patent.Business_Contact__c);        
            }
            
            if(patent.Docketing_Contact__c != null){
                setPatentUsers.add(patent.Docketing_Contact__c);        
            }
            
            if(patent.Symphony_IPM_Family_Attorney__c != null){
                setPatentUsers.add(patent.Symphony_IPM_Family_Attorney__c);        
            }
       
            if(patent.First_Named_Inventor__c != null){
                setPatentUsers.add(patent.First_Named_Inventor__c);        
            }
            
            if(patent.Foreign_Agent__c != null){
                setPatentUsers.add(patent.Foreign_Agent__c);        
            }
            
            if(patent.Inventor__c != null){
                setPatentUsers.add(patent.Inventor__c);        
            }
            
            if(patent.Paralegal__c != null){
                setPatentUsers.add(patent.Paralegal__c);        
            }
            
            if(patent.Portfolio_Manager__c != null){
                setPatentUsers.add(patent.Portfolio_Manager__c);        
            }
            
            if(patent.Primary_Inventor__c != null){
                setPatentUsers.add(patent.Primary_Inventor__c);        
            }
            
            if(patent.Prosecuting_Counsel__c != null){
                setPatentUsers.add(patent.Prosecuting_Counsel__c);        
            }
            
        }
        
        System.debug(setPatentUsers);
        if(!setPatentUsers.isEmpty()){
            PatentObjectQueuable pInstance=new PatentObjectQueuable();
            Set<Id> personManagerIds=pInstance.patenttoShareUsers(setPatentUsers);
            personManagerIds.addAll(setPatentUsers);
            
            if(!personManagerIds.isEmpty()){
                for(Inventor__c inventor:[SELECT User__c FROM Inventor__c WHERE Id IN : personManagerIds AND User__c != null])
                {
                    managerIds.add(inventor.User__c);
                }
                
                if(!managerIds.isEmpty()){
                    Map<Id,Id> mapPatentshareUsers=new Map<Id,Id>();
                    for(Patent__Share pShare:[SELECT UserOrGroupId FROM Patent__Share WHERE ParentId =: patentId AND RowCause = 'Manual'])
                    {
                        mapPatentshareUsers.put(pShare.UserOrGroupId,pShare.UserOrGroupId);
                    }
                    
                    for(Id userId:mapPatentshareUsers.keySet()){
                        if(managerIds.contains(userId)){
                            mapPatentshareUsers.remove(userId);
                            managerIds.remove(userId);
                        }
                    }
                    
                    if(!mapPatentshareUsers.isEmpty()){
                        Delete [Select Id from Patent__Share WHERE ParentId =: patentId AND RowCause = 'Manual' AND UserOrGroupId IN : mapPatentshareUsers.keySet()];
                    }
                    
                    if(!managerIds.isEmpty()){
                        List<Patent__Share> lstPatentShare =new List<Patent__Share>();
                        for(Id userId: managerIds){
                            Patent__Share pShare =new Patent__Share(ParentId = patentId, UserOrGroupId = userId,
                            AccessLevel = 'Read',RowCause = Schema.Patent__Share.RowCause.Manual);
                            lstPatentShare.add(pShare);
                        }
                        
                        System.debug(lstPatentShare);
                        If(!lstPatentShare.isEmpty()){
                            database.insert(lstPatentShare,false);
                        }
                    }
                }
                
            }else{
                Delete [Select Id from Patent__Share WHERE ParentId =: patentId AND RowCause = 'Manual'];
            }
            
            patentIds.remove(0);
            if(patentIds.size() >0){
                System.enqueueJob(new PatentObjectQueuable(patentIds)); 
            }
        }
    }
}
