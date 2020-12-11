public class SOOLWCEdit extends SOOLWCObject{
    
    @auraEnabled(cacheable=true)
    public static User getUserInfo(Id userId){
        User usr=[select Id,Profile.Name from User Where Id = : userId]; 
        return usr;
    }
    
    public class MilestoneTambaWrapper {
        @auraEnabled public List<Id> lstTamba;
        @auraEnabled public Map<Id,TAMBA__c> mapTamba;
        @auraEnabled public Boolean hasAccess;
        @auraEnabled public List<String> lstRDTargetMilestone;
        @auraEnabled public List<String> lstProdTargetMilestone;
        @auraEnabled public wrapper wrapper;
    }
    
    public class EventCalendarWrapper {
        @auraEnabled public SOO__c soo;
        @auraEnabled public List<Technology_RoadMap__c> lstRoadMap;
    }
    
    @AuraEnabled
    public static EventCalendarWrapper loadEventCalendar(Id recordid){
        EventCalendarWrapper wrapper=new EventCalendarWrapper();
        SOO__c soo=[Select Account__r.Name,Account__r.Managed_Account__c,TAMBA__r.AMAT_Node__r.Name,TAMBA__r.Customer_Node__r.Name,TAMBA__r.DTOR_Date__c,TAMBA__r.PTOR_Date__c,Development_Start_Date__c,Development_End_Date__c,Pilot_Start_Date__c,
        Pilot_End_Date__c,HVM_Start_Date__c,HVM_End_Date__c,Device_Qualification__c,DTOR_Tool_Decision__c,PTOR_Tool_Decision__c,Eval_Signoff__c,Demo__c,Onsite_Eval_Start_Date__c,Onsite_Eval_End_Date__c from SOO__c Where Id = :recordid];
        wrapper.soo =soo;
        System.debug(soo.TAMBA__r.Customer_Node__c);
        System.debug(soo.TAMBA__r.AMAT_Node__c);
        if(soo.TAMBA__c != null){
            wrapper.lstRoadMap=[SELECT AMAT_Node__c,Color_Code__c,Customer_Node__c,End_Date__c,Managed_Accounts__c,Managed_Account__c,Name,Stage__c,Start_Date__c FROM Technology_RoadMap__c WHERE AMAT_Node__c =: soo.TAMBA__r.AMAT_Node__c AND Customer_Node__c =: soo.TAMBA__r.Customer_Node__c];
            //wrapper.lstRoadMap=[SELECT AMAT_Node__c,Color_Code__c,Customer_Node__c,End_Date__c,Managed_Accounts__c,Managed_Account__c,Name,Stage__c,Start_Date__c FROM Technology_RoadMap__c WHERE AMAT_Node__c ='a110V00000bYbx7QAC' AND Customer_Node__c ='a1s0V000005oPWlQAM'];
        }
        return wrapper;
    } 
    
    @AuraEnabled
    public static MilestoneTambaWrapper loadmilestone(Id recordid)
    {
        MilestoneTambaWrapper mileWrapper=new MilestoneTambaWrapper();
        Wrapper wrapper=new Wrapper();
        wrapper.lstRecordsRd =new List<Sobject>();
        wrapper.lstRecordsProduction=new List<Sobject>();
        /*1hsection*/  
        wrapper.lstRecordsRd =[select id,Name,SOO__c,Milestone__c,Stage__c,DTOR_Date__c,PTOR_Date__c,Target_Date__c,Milestone_Status__c,TAMBA_Name__c,TAMBA_Name_Text__c,Application_Name_Customer__c,
                                Customer_Engagement__c,SIP_Objective_Owned_by_BM__c,Application_Name__c,Customer_Engagement1__c,Prioritized_TAMBA_FYs__c,Prioritize_TAMBA_FY18__c, Prioritize_TAMBA_FY19__c,Prioritize_TAMBA_FY20__c,Prioritize_TAMBA_FY21__c,Prioritize_TAMBA_FY17__c,PriorityStatus__c,Primary_Reason__c,Proof__c,Additional_Information__c from Milestone__c where SOO__c = :recordid AND Type__c = 'R&D' Order by TAMBA_Name__r.Name ];
        wrapper.lstRecordsProduction=[select id,Name,SOO__c,Milestone__c,Stage__c,DTOR_Date__c,PTOR_Date__c,Target_Date__c,Milestone_Status__c,TAMBA_Name__c,TAMBA_Name_Text__c,Application_Name_Customer__c,
                                Customer_Engagement__c,SIP_Objective_Owned_by_BM__c,Application_Name__c,Customer_Engagement1__c,Prioritized_TAMBA_FYs__c,Prioritize_TAMBA_FY18__c, Prioritize_TAMBA_FY19__c,Prioritize_TAMBA_FY20__c,Prioritize_TAMBA_FY21__c,Prioritize_TAMBA_FY17__c,PriorityStatus__c,Primary_Reason__c,Proof__c,Additional_Information__c from Milestone__c where SOO__c =:recordid AND Type__c = 'Production' Order by TAMBA_Name__r.Name ]; //
        List<Id> lstIds=new List<Id>();
        Map<Id,TAMBA__c> mapTamba=new Map<Id,TAMBA__c>();
        for(TAMBA__c tamba:SOOLWCEdit.loadTambafromSOO(recordid,'')){
            if(tamba.SOO__c == recordid){
                lstIds.add(tamba.Id);
                mapTamba.put(tamba.Id,tamba);
            }
        }
        
        Set<String> targetmilestone=new Set<String>();
        Set<String> prodtargetmilestone=new Set<String>();
        SOO__c soo=[Select Id,Account__c,Account__r.Name,Business_Unit__c from SOO__c Where Id =:recordid];
        System.debug(soo.Account__r.Name);
        
        String accountName =soo.Account__r.Name.toUpperCase();
        System.debug(accountName.contains('INTEL'));
        if(accountName.contains('INTEL')){
            for(Schema.PicklistEntry entry:Milestone__c.Milestone__c.getDescribe().getPicklistValues()){
                if(entry.getValue() == 'Qualify new application / layers' && soo.Business_Unit__c !='PDC'){
                    continue;
                }
                targetmilestone.add(entry.getValue());
                prodtargetmilestone.add(entry.getValue());
            }    
        }else if(soo.Business_Unit__c =='PDC'){
            for(Schema.PicklistEntry entry:Milestone__c.Milestone__c.getDescribe().getPicklistValues()){
                if(entry.getValue() == 'Co PTOR (with $ PO)' || entry.getValue() == 'Sole-PTOR (with $ PO)' || entry.getValue() == 'Maintain PTOR'){
                    prodtargetmilestone.add(entry.getValue());
                    continue;
                }else if(entry.getValue() == 'Co-DTOR (with $ PO)' || entry.getValue() == 'Sole-DTOR (with $ PO)'){
                    targetmilestone.add(entry.getValue());
                    continue;
                }
                prodtargetmilestone.add(entry.getValue());
                targetmilestone.add(entry.getValue());
                
            }
        }else{
            for(Schema.PicklistEntry entry:Milestone__c.Milestone__c.getDescribe().getPicklistValues()){
                if(entry.getValue() == 'Qualify new application / layers'){
                    continue;
                }else if(entry.getValue() == 'Co PTOR (with $ PO)' || entry.getValue() == 'Sole-PTOR (with $ PO)' || entry.getValue() == 'Maintain PTOR'){
                    prodtargetmilestone.add(entry.getValue());
                    continue;
                }else if(entry.getValue() == 'Co-DTOR (with $ PO)' || entry.getValue() == 'Sole-DTOR (with $ PO)'){
                    targetmilestone.add(entry.getValue());
                    continue;
                }
                targetmilestone.add(entry.getValue());
                prodtargetmilestone.add(entry.getValue());
            }
        }
        
        Profile profile=[Select Name from Profile Where Id = : UserInfo.getProfileId()];
        if(profile.Name == 'System Administrator' || profile.Name == 'BU BM' || profile.Name == 'Sales Ops SFDC Admins'){
            mileWrapper.hasAccess = true;
        }else{
            mileWrapper.hasAccess = false;
        }
           
        mileWrapper.lstTamba =lstIds;
        mileWrapper.mapTamba=mapTamba;
        mileWrapper.wrapper =wrapper;
        List<String> lstRd=new List<String>();
        lstRd.addAll(targetmilestone);
        List<String> lstProd=new List<String>();
        lstProd.addAll(prodtargetmilestone);
        mileWrapper.lstRDTargetMilestone= lstRd;
        mileWrapper.lstProdTargetMilestone= lstProd;
        system.debug(mileWrapper);
        return mileWrapper;
    }
    
    @AuraEnabled
    public static Boolean hasMilestoneStatusAccess()
    {
        Schema.DescribeFieldResult fieldResult=schema.sobjectType.Milestone__c.fields.Milestone_Status__c;
        system.debug(fieldResult.isUpdateable());
        return fieldResult.isUpdateable();
    }
    
    @auraEnabled
    public static AMAT_Employee__c fetchAMATEmployee(String recordid)
    {
        List<AMAT_Employee__c> employee=[Select Id from AMAT_Employee__c Where User__c = : recordid];
        if(!employee.isEmpty()){
            return employee[0];    
        }
        return null;
        
    }
    
    @auraEnabled
    public static Wrapper loaddecisionmakers(Id recordid)
    {
        
        Wrapper wrapper=new Wrapper();
        wrapper.lstRecordsRd=[Select id,name,Title1__c,Same_as_R_D__c,Title__c ,Purchase_Status__c,Purchase_Status1__c ,Buyer_TypeNa__c ,Commerical_Position__c ,Competitive_Alliance__c ,Influence_Level__c ,Position_to_SSO__c ,Buyer_Type__c ,
                                    Response_Mode__c ,Sales_Optimizer__c,Decision_Maker__c  from Decision_Makers__c WHERE Sales_Optimizer__c =:recordid AND Type__c = 'R&D' order by createddate];
        wrapper.lstRecordsProduction=[Select id,name,Same_as_R_D__c,Title1__c,Title__c ,Purchase_Status__c,Purchase_Status1__c ,Buyer_TypeNa__c ,Commerical_Position__c ,Competitive_Alliance__c ,Influence_Level__c ,Position_to_SSO__c ,Buyer_Type__c ,
                                    Response_Mode__c ,Sales_Optimizer__c,Decision_Maker__c  from Decision_Makers__c WHERE Sales_Optimizer__c =:recordid AND Type__c = 'Production' order by createddate];        
        return wrapper;
    }
    
    @auraEnabled
    public static String accountName(Id accId){
        return [Select Short_Name__c From Account Where Id = : accId AND Active__c =true].Short_Name__c;
    }
    
    @auraEnabled
    public static Wrapper loadTasks(Id recordid)
    {
        Wrapper wrapper=new Wrapper();
        /*1hsection*/  
        wrapper.lstRecordsRd =[Select id,Subject,Owner__c,Priority,Status,Same_as_R_D__c,ActivityDate,Non_SFDC_User_Action_Owner__c,Strategy__c  from task WHERE whatId=:recordid AND Type__c = 'R&D' AND Sub_Type__c != 'BU GM Help Needed']; //
        wrapper.lstRecordsProduction =[Select id,Subject,Owner__c,Priority,Status,Same_as_R_D__c,ActivityDate,Non_SFDC_User_Action_Owner__c,Strategy__c  from task WHERE whatId=:recordid AND Type__c = 'Production' AND Sub_Type__c != 'BU GM Help Needed']; //
        return wrapper;
    }
    
    @auraEnabled
    public static Wrapper loadConsequences(Id recordid)
    {
        Wrapper wrapper=new Wrapper();
        /*1hsection*/  
        wrapper.lstRecordsRd=[Select Id,Applied_CNA1__c,Applied_CNA_Value1__c,Customer_CNA1__c,Customer_CNA_Value1__c,SOO__c From Consequences_of_No_Agreement__c WHERE SOO__c = :recordid AND Type__c = 'R&D']; //
        wrapper.lstRecordsProduction =[Select Id,Applied_CNA1__c,Applied_CNA_Value1__c,Customer_CNA1__c,Customer_CNA_Value1__c,SOO__c From Consequences_of_No_Agreement__c WHERE SOO__c = :recordid AND Type__c = 'Production']; //
        return wrapper;
    }
    
    @auraEnabled
    public static Wrapper loadtradeTable(Id recordid)
    {
        Wrapper wrapper=new Wrapper();
        /*1hsection*/  
        wrapper.lstRecordsRd =[Select Id,Applied_Trade1__c,Applied_Trade_Value1__c,Customer_Trade1__c,Customer_Trade_Value1__c,SOO__c,AMAT_Priority__c,Customer_Priority__c From Trade_Table__c WHERE SOO__c = :recordid AND Type__c = 'R&D'];
        wrapper.lstRecordsProduction =[Select Id,Applied_Trade1__c,Applied_Trade_Value1__c,Customer_Trade1__c,Customer_Trade_Value1__c,SOO__c,AMAT_Priority__c,Customer_Priority__c From Trade_Table__c WHERE SOO__c = :recordid AND Type__c = 'Production']; //
        return wrapper;
    }
    
    @auraEnabled
    public static Wrapper loadpersonalwin(Id recordid)
    {
        Wrapper wrapper=new Wrapper();
        /*1hsection*/  
        wrapper.lstRecordsRd =[Select Id,Decision_Maker__c,Decision_Maker1__c, Corporate_WIN__c,Personal_WIN__c,Results_to_Deliver__c,Sales_Optimizer__c From Personal_Win__c WHERE Sales_Optimizer__c = :recordid];
        wrapper.lstRecordsProduction=[Select Id,Decision_Maker__c,Decision_Maker1__c, Corporate_WIN__c,Personal_WIN__c,Results_to_Deliver__c,Sales_Optimizer__c From Personal_Win__c WHERE Sales_Optimizer__c = :recordid];
        return wrapper;
    }
    
    @auraEnabled
    public static Wrapper loadhvps(Id recordid)
    {
        Wrapper wrapper=new Wrapper();
        /*1hsection*/  
        wrapper.lstRecordsRd =[Select Id,Customer_HVP__c,Same_as_R_D__c,SOO__c,Specifics__c From HVPs__c WHERE SOO__c = :recordid AND Type__c = 'R&D'];
        wrapper.lstRecordsProduction=[Select Id,Customer_HVP__c,Same_as_R_D__c,SOO__c,Specifics__c From HVPs__c WHERE SOO__c = :recordid AND Type__c = 'Production'];
        return wrapper;
    }
    
    @auraEnabled
    public static Wrapper loadareastrength(Id recordid)
    {
        Wrapper wrapper=new Wrapper();
        /*1hsection*/  
        wrapper.lstRecordsRd=[Select Id,Identify_Areas_of_Strength_Category__c,Same_as_R_D__c,SOO__c,Specifics__c From Area_of_Strength__c WHERE SOO__c = :recordid AND Type__c = 'R&D'];
        wrapper.lstRecordsProduction=[Select Id,Identify_Areas_of_Strength_Category__c,Same_as_R_D__c,SOO__c,Specifics__c From Area_of_Strength__c WHERE SOO__c = :recordid AND Type__c = 'Production'];
        return wrapper;
    }
    
    public class ExecutiveHelpWrapper {
        @auraEnabled public String BUHead;
        @auraEnabled public String BUBM;
        @auraEnabled public Boolean hasAccess;
        @auraEnabled public List<Sobject> lstRecordsRd;
        @auraEnabled public List<Sobject> lstRecordsProduction;
    }
    
    @auraEnabled
    public static ExecutiveHelpWrapper loadexecutivehelp(Id recordid)
    {
        ExecutiveHelpWrapper wrapper=new ExecutiveHelpWrapper();
        /*1hsection*/  
        wrapper.lstRecordsRd =[Select id,Subject,Priority,BU_GM_Name__c,BU_Acceptance__c,Status,Same_as_R_D__c,ActivityDate,Non_SFDC_User_Action_Owner__c,Strategy__c  from task WHERE whatId=:recordid AND Type__c = 'BU GM R&D' AND Sub_Type__c = 'BU GM Help Needed']; //
        wrapper.lstRecordsProduction =[Select id,Subject,BU_GM_Name__c,Priority,BU_Acceptance__c,Status,Same_as_R_D__c,ActivityDate,Non_SFDC_User_Action_Owner__c,Strategy__c  from task WHERE whatId=:recordid AND Type__c = 'BU GM Production' AND Sub_Type__c = 'BU GM Help Needed']; //
        
        Profile profile=[Select Name from Profile Where Id = : UserInfo.getProfileId()];
        if(profile.Name == 'System Administrator' || profile.Name == 'BU BM' || profile.Name == 'Sales Ops SFDC Admins'){
            wrapper.hasAccess = true;
        }else{
            wrapper.hasAccess = false;
        }
        
        SOO__c soo=[Select Id,Business_Unit__c from SOO__c Where Id =:recordid ];
        System.debug(soo.Business_Unit__c);
        List<String> businessUnits=soo.Business_Unit__c.split(';');
        
        String query='SELECT Business_Unit__c,Id,Key_Business_Role__c FROM AMAT_Employee__c Where Business_Unit__c Includes (' + '\'' + String.join(businessUnits,'\',\'') +'\'' +') ';
        System.debug(query);        
        for(AMAT_Employee__c emp:Database.query(query)){
            if(emp.Key_Business_Role__c =='BM Head'){
               wrapper.BUHead = emp.Id;
            }else if(emp.Key_Business_Role__c =='BU GM'){
               wrapper.BUBM  = emp.Id;
            }
        }
        
        //wrapper.lstRecordsRd =[SELECT Help_Needed__c,Same_as_R_D__c,BU_Owner__c,Due_Date__c,Id,Name,SOO__c,Status__c FROM Executive_Help_Needed__c Where SOO__c = :recordid AND Type__c = 'R&D'];
        //wrapper.lstRecordsProduction=[SELECT Help_Needed__c,Same_as_R_D__c,BU_Owner__c,Due_Date__c,Id,Name,SOO__c,Status__c FROM Executive_Help_Needed__c Where SOO__c = :recordid AND Type__c = 'Production'];
        return wrapper;
    }
    
    @auraEnabled
    public static Wrapper loadredflagstrategy(Id recordid)
    {
        Wrapper wrapper=new Wrapper();
        /*1hsection*/  
        wrapper.lstRecordsRd=[SELECT Category__c,Specifics__c,Same_as_R_D__c,Strategy_to_Overcome_Specifics__c FROM Red_Flag_and_Strategy__c Where SOO__c = :recordid AND Type__c = 'R&D'];
        wrapper.lstRecordsProduction=[SELECT Category__c,Specifics__c,Same_as_R_D__c,Strategy_to_Overcome_Specifics__c FROM Red_Flag_and_Strategy__c Where SOO__c = :recordid AND Type__c = 'Production'];
        return wrapper;
    }
    
    @auraEnabled
    public static ProductscorecardSummary.ProductscorecardWrapper loadPSC(Id recordId) //,Id recordId
    {
        System.debug(recordId);
        SOO__c soo=[Select Id,TAMBA__r.Product_Scorecard__c from SOO__c Where Id =: recordId];
        if(soo.TAMBA__r.Product_Scorecard__c != null){
            return ProductscorecardSummary.processProductScoreCard(soo.TAMBA__r.Product_Scorecard__c);
        }
        return null;
    }
    
    
    @auraEnabled
    public static List<TAMBA__c> loadtambaIds(List<String> tambaIds) //,Id recordId
    {
        System.debug(tambaIds);
        return [Select Id,Name from TAMBA__c Where Id IN : tambaIds];
    }
    
    @auraEnabled
    public static Map<Id,String> loadPWinDecisionMakers(Id recordid) //,Id recordId
    {
        Map<Id,String> mapcontacts=new Map<Id,String>();
        
        for(Decision_Makers__c dMaker:[Select Id,Decision_Maker__c,Decision_Maker__r.Name from Decision_Makers__c where Sales_Optimizer__c = :recordid AND Decision_Maker__c != null]){
            mapcontacts.put(dMaker.Decision_Maker__c,dMaker.Decision_Maker__r.Name);
            //lst.add(dMaker.Decision_Maker__r.Name);
        }
        return mapcontacts;
    }
    
    @auraEnabled
    public static list<Product_Scorecard_Products__c> loadPSCfromTAMBA(String tambaName){//
        System.debug('Tamba Names');
        return [Select Id,Name From Product_Scorecard_Products__c Where TAMBA__c =:tambaName]; //AND Soo__c =: sooId 
    }
    
    @auraEnabled
    public static list<TAMBA__c> loadTambafromSOO(Id recordId,String priority){
        System.debug(priority);
        SOO__c soo=[Select Id,Account__c,Business_Unit__c,TAMBA_Priority__c from SOO__c Where Id =: recordId];
        return SOOLWCEdit.loadtamba(soo.Account__c,soo.Business_Unit__c,(priority != ''?priority:soo.TAMBA_Priority__c),soo.Id);
    }
    
    public class Tamba {
        @auraEnabled
        public TAMBA__c tambaRec;
        @auraEnabled
        public Decimal totalRevenue;
        @auraEnabled
        public List<Technology_RoadMap__c> lstRoadMap;
    }
    
    @auraEnabled
    public static Tamba loadPrimaryTamba(Id recordId){
        Tamba tamba=new Tamba();
        SOO__c soo=[Select Id,TAMBA__c,TAMBA__r.Customer_Node__c,TAMBA__r.AMAT_Node__c from SOO__c Where Id =: recordId];
        Decimal revenue=0;
        if(soo.TAMBA__c != null){
            for(TAMBA__c t:[Select Id,(Select Id,Opportunity_ID__c from SSG_Opportunities__r limit 1),Competitor_Company__c,Competitor_Tool__c,Competitor_Company__r.Name,Competitor_Tool__r.Name,SOO__c,Name,Total_Revenue__c,AMAT_Node__r.Name,Device_Type__r.Name,AMAT_Product_G3__c,AMAT_Product_G3__r.Name,Customer_Node__r.Name,Application_Name_Customer__r.Name,Account__c,
                                                BU__c,Customer_Node__c,AMAT_Node__c,Segment__c,Device_Type__c,Application_Name_Customer__c,Prioritize_TAMBA_FY17__c,Prioritized_TAMBA_FYs__c,DTOR_Date__c,PTOR_Date__c,Product_Scorecard__c,
                                                Prioritize_TAMBA_FY18__c,Prioritize_TAMBA_FY19__c,Prioritize_TAMBA_FY20__c,Prioritize_TAMBA_FY21__c,Customer_Engagement__c,Criticality__c,Differentiation__c,Engineering_Adoption_Probability__c
                                            FROM 
                                                TAMBA__c Where SOO__c = : recordId]){
                        if(soo.TAMBA__c == t.Id){
                            tamba.tambaRec =t;
                        }
                        if(t.Total_Revenue__c != null){
                            revenue +=t.Total_Revenue__c;
                        }
            }
            tamba.totalRevenue=revenue;
            tamba.lstRoadMap=[SELECT AMAT_Node__c,Color_Code__c,Customer_Node__c,End_Date__c,Managed_Accounts__c,Managed_Account__c,Name,Stage__c,Start_Date__c FROM Technology_RoadMap__c WHERE AMAT_Node__c =: soo.TAMBA__r.AMAT_Node__c AND Customer_Node__c =: soo.TAMBA__r.Customer_Node__c];
                //wrapper.lstRoadMap=[SELECT AMAT_Node__c,Color_Code__c,Customer_Node__c,End_Date__c,Managed_Accounts__c,Managed_Account__c,Name,Stage__c,Start_Date__c FROM Technology_RoadMap__c WHERE AMAT_Node__c ='a110V00000bYbx7QAC' AND Customer_Node__c ='a1s0V000005oPWlQAM'];
            
            return tamba;
        }
        return null;
    }
    
    
    @auraEnabled
    public static list<TAMBA__c> loadtamba(String accountId,String businessUnit,String status,String sooId) //,
    {
        try{
            System.debug(accountId);
            System.debug(businessUnit);
            System.debug(status);
            Map<Id,TAMBA__c> maptamba=null;
            List<String> bunit =businessUnit.split(';');
            System.debug(bunit);
            Account acc=[Select Managed_Account__c from Account where Id = : accountId];
            if(status == 'Yes')
            {
                return [Select id,SOO__c,Primary_Tamba__c,Name,Total_Revenue__c,DTOR_Date__c,PTOR_Date__c,AMAT_Node__r.Name,Device_Type__r.Name,Customer_Node__r.Name,Application_Name_Customer__r.Name,Account__c,
                                                BU__c,Customer_Node__c,AMAT_Node__c,Segment__c,Device_Type__c,Application_Name_Customer__c,Prioritize_TAMBA_FY17__c,Prioritized_TAMBA_FYs__c,
                                                Prioritize_TAMBA_FY18__c,Prioritize_TAMBA_FY19__c,Prioritize_TAMBA_FY20__c,Prioritize_TAMBA_FY21__c,Customer_Engagement__c,Criticality__c,Differentiation__c,Account_Adoption_Probability__c
                                            FROM 
                                                TAMBA__C 
                                            Where 
                                                BU__c IN :bunit
                                            AND 
                                                Managed_Account__c =: acc.Managed_Account__c
                                            AND (SOO__c = null OR SOO__c =: sooId)
                                            AND (Prioritize_TAMBA_FY17__c =:status OR Prioritize_TAMBA_FY18__c=:status OR Prioritize_TAMBA_FY19__c=:status OR Prioritize_TAMBA_FY20__c=:status OR Prioritize_TAMBA_FY21__c=:status ) 
                                            AND (Prioritize_TAMBA_FY17__c !='No' OR Prioritize_TAMBA_FY18__c !='No' OR Prioritize_TAMBA_FY19__c !='No' OR Prioritize_TAMBA_FY20__c !='No' OR Prioritize_TAMBA_FY21__c!='No')
                                            order by Name Asc];
            }else if(status == 'No'){
                maptamba=new Map<Id,TAMBA__c>([Select id,SOO__c,Name,Total_Revenue__c,DTOR_Date__c,PTOR_Date__c,Primary_Tamba__c,AMAT_Node__r.Name,Device_Type__r.Name,Customer_Node__r.Name,Application_Name_Customer__r.Name,Account__c,
                                                BU__c,Customer_Node__c,AMAT_Node__c,Segment__c,Device_Type__c,Application_Name_Customer__c,Prioritize_TAMBA_FY17__c,Prioritized_TAMBA_FYs__c,
                                                Prioritize_TAMBA_FY18__c,Prioritize_TAMBA_FY19__c,Prioritize_TAMBA_FY20__c,Prioritize_TAMBA_FY21__c,Customer_Engagement__c,Criticality__c,Differentiation__c,Account_Adoption_Probability__c from TAMBA__C where BU__c IN :bunit
                                                AND Managed_Account__c =: acc.Managed_Account__c
                                                AND (SOO__c = null OR SOO__c =: sooId)
                                                AND (Prioritize_TAMBA_FY17__c !='Yes' AND Prioritize_TAMBA_FY18__c !='Yes' AND Prioritize_TAMBA_FY19__c !='Yes' AND Prioritize_TAMBA_FY20__c !='Yes' AND Prioritize_TAMBA_FY21__c !='Yes')
                                                order by Name Asc]);
            }else if(status == 'Both')
            {
                maptamba=new Map<Id,TAMBA__c>([Select id,SOO__c,Total_Revenue__c,DTOR_Date__c,PTOR_Date__c,Name,Primary_Tamba__c,AMAT_Node__r.Name,Device_Type__r.Name,Customer_Node__r.Name,Application_Name_Customer__r.Name,Account__c,BU__c,
                                                Customer_Node__c,AMAT_Node__c,Segment__c,Device_Type__c,Application_Name_Customer__c,Prioritize_TAMBA_FY17__c,Prioritize_TAMBA_FY18__c,Prioritized_TAMBA_FYs__c,
                                                Prioritize_TAMBA_FY19__c,Prioritize_TAMBA_FY20__c,Prioritize_TAMBA_FY21__c,Customer_Engagement__c,Criticality__c,Differentiation__c,Account_Adoption_Probability__c from TAMBA__C where BU__c IN : bunit
                                                and Managed_Account__c =: acc.Managed_Account__c]);
            }
            
            return maptamba.values();
        }catch(Exception e)
        {
            System.debug(e.getMessage());
        }
        return null;  
    }
    
    
    /*public static List<Sobject> parseObject(String objdata,String objName,String type){
        
        List<Sobject> lstSobject=new List<Sobject>();
        List<Object> lstData=(List<Object>)JSON.deserializeUntyped(objdata);
        for(Object obj:lstData){
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
            Sobject objRecord=objType.newSObject();
            Map<String,Schema.SObjectField> mapfields=objType.getDescribe().fields.getMap();
            lstSobject.add(objRecord);
        }
        return lstSobject;
    }*/
    
    @auraEnabled
    public static Id loadPSCFromTambaId(Id recordId){
        SOO__c soo=[Select Id,TAMBA__c,TAMBA__r.Customer_Node__c,TAMBA__r.AMAT_Node__c from SOO__c Where Id =: recordId];
        if(soo.TAMBA__c != null){
            TAMBA__c t=[Select Id,Product_Scorecard__c FROM 
                                                TAMBA__c Where Id = : soo.TAMBA__c];
            return t.Product_Scorecard__c;
        }
        return null;
    }
    
    @future
    public static void updateTamba(String lstTambaIds,String sooId,String pscId){
        try{
        
        SOO__c soo=[Select Id from SOO__c Where Id = : sooId FOR UPDATE];
        
        if(pscId != ''){
            List<Product_Scorecard_Products__c> lstProducts=new List<Product_Scorecard_Products__c>();
            for(Product_Scorecard_Products__c products:[Select Id,SOO__c from Product_Scorecard_Products__c Where Id =: pscId FOR UPDATE]){
                if(products.SOO__c != sooId){
                products.SOO__c = sooId;
                lstProducts.add(products);
                }
            }
            
            if(!lstProducts.isEmpty()){
                update lstProducts;
            }
        }
        
        Map<Id,TAMBA__c> mapTamba=new Map<Id,TAMBA__c>([Select Id FROM TAMBA__c Where SOO__c = : soo.Id]);
        List<TAMBA__c> lstUpdTamba=new List<TAMBA__c>();
        for(Object obj:(List<Object>)JSON.deserializeUntyped(lstTambaIds)){
            String tambaId =String.valueOf(obj);
            if(mapTamba.containsKey(tambaId)){
               mapTamba.remove(tambaId); 
            }
            TAMBA__c tam=new TAMBA__c(Id =tambaId,SOO__c = sooId);
            lstUpdTamba.add(tam);
        }
        
        if(!mapTamba.isEmpty()){
            for(Id tambaId:mapTamba.keySet()){
                TAMBA__c tam=new TAMBA__c(Id =tambaId,SOO__c = null);
                lstUpdTamba.add(tam);    
            }
        }
        
        
        if(!lstUpdTamba.isEmpty()){
            update lstUpdTamba;
        }
        }catch(Exception e){
            System.debug(e.getMessage() + e.getStacktraceString());
            
        }
    }
    
    @auraEnabled
    public static String savesOOInTAMBA(String lstTambaIds,String sooId,String pscId) 
    {
        System.debug(lstTambaIds);
        System.debug(sooId);
        if(sooId == null || sooId ==''){
            return 'Error: Record should not null';
        }
        SOOLWCEdit.updateTamba(lstTambaIds,sooId,pscId);
        return sooId;
    }
    
    @auraEnabled
    public static String saveChildRecords(String objdata,String parentRecord,String type,String objName,String parentApiName) //,String proddata
    {
        try{
        System.debug(parentRecord);
        System.debug(objdata);
        //System.debug(proddata);
        System.debug(type);
        
        if(parentRecord == null || parentRecord ==''){
            return 'Error: Parent Record should not null';
        }
        
        
        String dynamicQuery='Select Id from ' +  objName + ' Where ' + parentApiName + ' = ' + '\'' + parentRecord + '\'' + ' AND Type__c = ' + '\'' + type + '\'';
        System.debug(dynamicQuery);
        Map<Id,Sobject> mapObjRecords=new Map<Id,Sobject>(Database.query(dynamicQuery));
        
        SOOLWCEdit lwcEdit=new SOOLWCEdit();
        List<Sobject> lstInsert=new List<Sobject>();
        List<Sobject> lstUpdate=new List<Sobject>();
        //lstDecisionMakers.addAll((List<Decision_Makers__c>)lwcEdit.parseObject(proddata,'Decision_Makers__c','Production'));
        
        for(Sobject objRecord:lwcEdit.parseObject(objdata,objName,type)){
            if(objRecord.Id != null){
                mapObjRecords.remove(objRecord.Id);
            }
            objRecord.put(parentApiName,parentRecord);
            System.debug(objRecord.get('Id'));
            if(objRecord.get('Id') != null){
                lstUpdate.add(objRecord);
            }else{
                lstInsert.add(objRecord);
            }
        }
        
        if(!lstUpdate.isEmpty()){
            update lstUpdate;
        }
        
        if(!lstInsert.isEmpty()){
            insert lstInsert;
        }
        
        
        if(!mapObjRecords.isEmpty()){
            List<Id> lstDeleteIds=new List<Id>();
            lstDeleteIds.addAll(mapObjRecords.keySet());
            SOOLWCEdit.deleteObjects(lstDeleteIds,objName);
            /*String response=
            if(response.startswith('Error')){
                return response;
            }*/
        }
        }catch(exception e){
            System.debug(e.getMessage() + '--'+ e.getStacktraceString());
            return 'Error:' +e.getMessage() + '--'+ e.getStacktraceString();
        }
        return parentRecord;
    }
    
}