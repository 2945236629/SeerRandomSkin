package
{
   import com.robot.core.CommandID;
   import com.robot.core.info.UserInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.net.SocketConnection;
   import flash.display.MovieClip;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import flash.external.ExternalInterface;
   import com.robot.core.manager.MainManager;
   import com.robot.core.info.fightInfo.attack.UseSkillInfo;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.petFightModule_201308.view.TimerManager;
   import com.robot.core.info.fightInfo.ChangePetInfo;
   import com.robot.core.manager.SystemTimerManager;
   import com.robot.core.info.fightInfo.FightStartInfo;
   import com.robot.app.task.petstory.util.KTool;
   import com.robot.core.info.fightInfo.NoteReadyToFightInfo;
   import com.robot.core.info.fightInfo.FightStartInfo;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.manager.MapManager;
   import com.robot.core.config.xml.MapXMLInfo;
   import com.robot.core.info.pet.PetStorage2015PetInfo;
   import com.codecatalyst.promise.Promise;
   import com.robot.core.behavior.ChangeClothBehavior;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.ui.alert.SimpleAlarm;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.app.fight.FightManager;
    import com.robot.core.info.pet.PetShowInfo;
   import flash.utils.getDefinitionByName;
   import com.robot.app2.control.activityHelper.ActivityHelperManager;
   import com.robot.app2.control.activityHelper.helps.SimpleHelper;
    import com.codecatalyst.promise.Deferred;
   import flash.utils.setTimeout;
   import com.robot.core.manager.UserInfoManager;
   import flash.utils.IDataInput;
   
   [Embed(source="/_assets/assets.swf", symbol="item")]
   public dynamic class item extends MovieClip
   {
       
      
      public function item()
      {
         super();

         if (SocketConnection.WxIsAutoCure != null) return;

         SocketConnection.WxCallback = function(result:* = null):void { ExternalInterface.call("WxFightHandler.Private._as3Callback",result); }

         // ��ͼ
         ExternalInterface.addCallback("WxChangeMapRandom",function():uint
         {
            var mapList:Array = MapXMLInfo.getIDList();
            var id:uint = mapList[Math.round(Math.random() * mapList.length)];
            MapManager.changeMap(id);
            return id;
         });

         // ���������û�
         ToolBarController.showOrHideAllUser(false);

         // �ص��
         SocketConnection.send(41162,0);

         /// ��ս���

         // �Զ�����
         SocketConnection.WxIsAutoCure = true;
         SocketConnection.WxCurePetAll = function():void
         {
            var bagBoth:Array = PetManager.getBagMap(true);
            for (var i:int = 0; i < bagBoth.length; ++i) SocketConnection.send(CommandID.PET_ONE_CURE,bagBoth[i].catchTime);
         }
         SocketConnection.addCmdListener(CommandID.FIGHT_OVER,function(event:SocketEvent) : void
         {
            if (SocketConnection.WxIsAutoCure) SocketConnection.WxCurePetAll();
            var fightOverInfo:FightOverInfo = event.data as FightOverInfo;
            ExternalInterface.call("WxFightHandler.OnFightOver",fightOverInfo);
         });

         // ʹ�ü���
         ExternalInterface.addCallback("WxUseSkill",function(skillID:uint):void { SocketConnection.send(CommandID.USE_SKILL,skillID); });

         // �л�����
         SocketConnection.WxChangePet = function(petCatchTime:uint):void
         {
            for each(var pet in SocketConnection.WxFightingPets) {
                if (pet.catchTime == SocketConnection.WxFightingPetCatchTime) {
                    // ��������л�
                    if (pet.hp > 0) { SocketConnection.WxIsPositiveChangePet = true; break; }
                }
            }
            SocketConnection.send(CommandID.CHANGE_PET,petCatchTime);
         };
         ExternalInterface.addCallback("WxChangePetByID",function(ids:Array):void
         {
            if (ids.length == 0) {
                for each(var pet in SocketConnection.WxFightingPets) {
                    if (pet.hp > 0 && pet.catchTime != SocketConnection.WxFightingPetCatchTime) { SocketConnection.WxChangePet(pet.catchTime); break; }
                }
                return;
            }
            for each(var id:int in ids) {
                for each(var pet in SocketConnection.WxFightingPets) {
                    if (pet.hp > 0 && pet.catchTime != SocketConnection.WxFightingPetCatchTime && pet.id == id) { SocketConnection.WxChangePet(pet.catchTime); return; }
                }
            }
            for each(var pet in SocketConnection.WxFightingPets) {
                if (pet.hp > 0 && pet.catchTime != SocketConnection.WxFightingPetCatchTime) { SocketConnection.WxChangePet(pet.catchTime); break; }
            }
            ExternalInterface.call("console.log","δ�ҵ�ָ�� id �ľ���",ids);
         });

         // ʹ��ҩ��
         ExternalInterface.addCallback("WxUsePetItem", function(itemID:uint):void { SocketConnection.send(CommandID.USE_PET_ITEM,SocketConnection.WxFightingPetCatchTime,itemID,0); });
         ExternalInterface.addCallback("WxItemBuy", function(itemID:uint):void { SocketConnection.send(CommandID.ITEM_BUY,itemID,1); });

         // �Զ�����
         // ����ս��
         SocketConnection.addCmdListener(CommandID.NOTE_READY_TO_FIGHT,function(event:SocketEvent):void
         {
            var readyData:NoteReadyToFightInfo = event.data as NoteReadyToFightInfo;
            SocketConnection.WxFightingPets = []; // �����л����鹦��
            var skillIndex:uint = 0;
            for each(var petInfo:PetInfo in readyData.userInfos.myInfo.petInfoArr) {
                var pet:Object = new Object();
                pet.id = petInfo.id;
                pet.catchTime = petInfo.catchTime;
                pet.hp = petInfo.hp;
                pet.skillArray = [];
                for (var i:int = 0; i < Math.min(4,petInfo.skillNum); ++i, ++skillIndex) {
                    pet.skillArray.push(readyData.userInfos.allSkillID[skillIndex]);
                }
                pet.hideSKill = petInfo.hideSKill;
                SocketConnection.WxFightingPets.push(pet);
            }
            ExternalInterface.call("WxFightHandler.Private.RoundReset");
            SocketConnection.WxIsPositiveChangePet = false;
         });
         // �׷�������Ϣ
         SocketConnection.addCmdListener(CommandID.NOTE_START_FIGHT,function(event:SocketEvent):void
         {
            var _loc2_:FightStartInfo = event.data as FightStartInfo;
            SocketConnection.WxFightingPetCatchTime = _loc2_.myInfo.catchTime;
            SocketConnection.WxFightingPetID = _loc2_.myInfo.petID;
            ExternalInterface.call("WxFightHandler.OnFirstRound",_loc2_);
         });
         // ʹ�ü���
         SocketConnection.addCmdListener(CommandID.NOTE_USE_SKILL, function(param1:SocketEvent) : void
         {
            var mySkillInfo:AttackValue;
            var enemySkillInfo:AttackValue;
            var _loc2_:UseSkillInfo = param1.data as UseSkillInfo;
            var isMeFirst:Boolean = true;
            if (_loc2_.firstAttackInfo.userID == MainManager.actorInfo.userID)
            {
               mySkillInfo = _loc2_.firstAttackInfo;
               enemySkillInfo = _loc2_.secondAttackInfo;
            }
            else
            {
               mySkillInfo = _loc2_.secondAttackInfo;
               enemySkillInfo = _loc2_.firstAttackInfo;
               isMeFirst = false;
            }

            for (var i:int = 0; i < SocketConnection.WxFightingPets.length; ++i) {
                if (SocketConnection.WxFightingPets[i].catchTime == SocketConnection.WxFightingPetCatchTime) {
                    SocketConnection.WxFightingPets[i].hp = mySkillInfo.remainHP;
                    break;
                }
            }
            for each(var pet in mySkillInfo.changehps) {
                for (var i:int = 0; i < SocketConnection.WxFightingPets.length; ++i) {
                    if (SocketConnection.WxFightingPets[i].catchTime == pet.id) {
                        SocketConnection.WxFightingPets[i].hp = pet.hp;
                        break;
                    }
                }
            }

            ExternalInterface.call("WxFightHandler.Private.ShowRound",(mySkillInfo.maxHp == 0 ? 0 : mySkillInfo.remainHP * 100 / mySkillInfo.maxHp),(enemySkillInfo.maxHp == 0 ? 0 : enemySkillInfo.remainHP * 100 / enemySkillInfo.maxHp));
            if (enemySkillInfo.remainHP == 0)
            {
                var isEnemyAllDead:Boolean = true;
                for (var i:int = 0; i < enemySkillInfo.changehps.length; ++i)
                {
                    if (enemySkillInfo.changehps[i].hp > 0)
                    {
                        isEnemyAllDead = false; break;
                    }
                }
                if (isEnemyAllDead)
                {
                    return;
                }
            }

            ExternalInterface.call("WxFightHandler.OnUseSkill",mySkillInfo,enemySkillInfo,isMeFirst);
         });
         // �л�����
         SocketConnection.addCmdListener(CommandID.CHANGE_PET,function(param1:SocketEvent):void
        {
            var _loc2_:ChangePetInfo = param1.data as ChangePetInfo;
            // �����л�
            if (_loc2_.userID == MainManager.actorInfo.userID) {
                SocketConnection.WxFightingPetID = _loc2_.petID;
                SocketConnection.WxFightingPetCatchTime = _loc2_.catchTime;
                if (SocketConnection.WxIsPositiveChangePet)
                {
                    SocketConnection.WxIsPositiveChangePet = false;
                }
                else
                {
                    // �����л�����ܳ���
                    ExternalInterface.call("WxFightHandler.OnChangePet",_loc2_);
                }
            }
        });

         // ѹѪ
         ExternalInterface.addCallback("WxCurePet20HP",function():void
         {
            SocketConnection.send(CommandID.ITEM_BUY,300011,6);
            SocketConnection.send(CommandID.ITEM_BUY,300017,6);
            var bag:Array = PetManager.getBagMap();
            for each(var pet in bag)
            {
                SocketConnection.send(CommandID.USE_PET_ITEM_OUT_OF_FIGHT,pet.catchTime,300011);
                SocketConnection.send(CommandID.USE_PET_ITEM_OUT_OF_FIGHT,pet.catchTime,300017);
            }
         });
         ExternalInterface.addCallback("WxLowHP",function():void { SocketConnection.send(41129, (SystemTimerManager.sysBJDate.hours < 12 || SystemTimerManager.sysBJDate.hours >= 15) ? 8692 : 8694); });

         // ��ȡ�ֿ⾫��
         SocketConnection.WxGetStoragePets = function(allInfo:Array,startID:int = 1):void
         {
            SocketConnection.sendWithPromise(45543,[startID - 1,startID + 998]).then(function(e:SocketEvent):void
            {
                var b:ByteArray = e.data as ByteArray;
                var len:int = int(b.readUnsignedInt());
                for(var i:int = 0; i < len; i++)
                {
                   allInfo.push(new PetStorage2015PetInfo(b));
                }
                if(len == 1000)
                {
                   SocketConnection.WxGetStoragePets(allInfo,startID + 1000);
                }
                else
                {
                   SocketConnection.WxCallback(allInfo);
                }
            });
         };
         ExternalInterface.addCallback("WxGetStoragePets",function():void { SocketConnection.WxGetStoragePets([]); });
         // ����
        ExternalInterface.addCallback("WxClearBag",function():void
        {
            var bagBoth:Array = PetManager.getBagMap(true);
            if (bagBoth.length > 0) {
                var promises:Array = new Array();
                for each(var pet in bagBoth) { promises.push(PetManager.bagToInStorage(pet.catchTime)); }
                Promise.all(promises).then(function():void { SocketConnection.WxCallback(); });
            }
            else {
                SocketConnection.WxCallback();
            }
        });
        ExternalInterface.addCallback("WxSetBag1",function(bag:Array):void
        {
            if (bag.length > 0) {
                var promises:Array = new Array();
                for each(var pet in bag) { promises.push(PetManager.storageToInBag(pet)); }
                Promise.all(promises).then(function():void { SocketConnection.WxCallback(); });
            }
            else {
                SocketConnection.WxCallback();
            }
        });
        ExternalInterface.addCallback("WxSetBag2",function(bag:Array):void
        {
            if (bag.length > 0) {
                var promises:Array = new Array();
                for each(var pet in bag) { promises.push(PetManager.storageToSecondBag(pet)); }
                Promise.all(promises).then(function():void { SocketConnection.WxCallback(); });
            }
            else {
                SocketConnection.WxCallback();
            }
        });

         ExternalInterface.addCallback("WxChangeCloth", function(clothes:Array):void
         {
            var clothArray:Array = [];
            for (var i:int = 0; i < clothes.length; i+=2)
            {
                clothArray.push(new PeopleItemInfo(clothes[i],clothes[i+1]));
            }
            MainManager.actorModel.execBehavior(new ChangeClothBehavior(clothArray));
         }
         );

         ExternalInterface.addCallback("WxSetTitle", function(title:uint):void
         {
            if (MainManager.actorInfo.curTitle != title) {
            SocketConnection.sendWithCallback(CommandID.SETTITLE,function(param1:SocketEvent):void
            {
                var _loc2_:ByteArray = null;
                if(param1.data)
                {
                    _loc2_ = param1.data as ByteArray;
                    MainManager.actorInfo.curTitle = _loc2_.readUnsignedInt();
                }
                else
                {
                    MainManager.actorInfo.curTitle = 0;
                }
                MainManager.actorModel.refreshTitle(MainManager.actorInfo.curTitle);
            },title);
            }
         }
         );

            SocketConnection.WxCopyFireByUserID = function(userid:int):void { SocketConnection.send(CommandID.FIRE_ACT_COPY,userid); }
            // ���Ĭ���̻�
            ExternalInterface.addCallback("WxCopyFireFromMap", function(fireTypes:Array = null):void
            {
                if (fireTypes == null) {
                    fireTypes = [5,6];
                }
                SocketConnection.sendWithCallback(CommandID.LIST_MAP_PLAYER,function(param1:SocketEvent):void
                {
                    var byteArray:ByteArray = param1.data as ByteArray;
                    var len:uint = byteArray.readUnsignedInt();
                    var userInfo:UserInfo = new UserInfo();
                    for (var i:int = 0; i < len; ++i)
                    {
                        UserInfo.setForPeoleInfo(userInfo,byteArray);
                        if (fireTypes.indexOf(userInfo.fireBuff) != -1)
                        {
                            SocketConnection.WxCopyFireByUserID(userInfo.userID);
                            SocketConnection.WxCallback(true);
                            return;
                        }
                    }
                    SocketConnection.WxCallback(false);
                });
            });
            // ���а�
            ExternalInterface.addCallback("WxGetRankListLen", function(key:int, sub_key:int):void
            {
                // key��120 ������182 ��Ұ��157 ͼ�����������֣�
                KTool.getRankListLen(key,sub_key,function(len:int):void
                {
                    SocketConnection.WxCallback(len);
                });
            });
            // �����а��ϵĻ�Ծ��ҽ��
            ExternalInterface.addCallback("WxCopyFireFromRank", function(key:int, sub_key:int, offset:int, fireTypes:Array = null):void
            {
                if (fireTypes == null) {
                    fireTypes = [5,6];
                }
                KTool.getBingLieRangeRankList(key,sub_key,offset,offset+99).then(function(l:Array):void
                {
                    // ��ȡ���е��������
                    var userIDs:Array = [];
                    for each (var o:Object in l) {
                        userIDs.push(o.userid);
                    }
                    var promises:Array = [];
                    UserInfoManager.seeOnLine(userIDs,function(onlineSeer:Array):void
                    {
                        if (onlineSeer.length == 0) {
                            SocketConnection.WxCallback(false);
                            return;
                        }
                        for each (var s:Object in onlineSeer) {
                            promises.push(SocketConnection.WxCopyFirePromise(s.userID,fireTypes));
                        }
                        Promise.all(promises).then(function(results:Array):void
                        {
                            SocketConnection.WxCallback(results.indexOf(true) != -1);
                        });
                    });
                });
            });
            SocketConnection.WxCopyFirePromise = function(userid:int, fireTypes:Array):Promise
            {
                var d:Deferred = new Deferred();
                SocketConnection.sendWithPromise(CommandID.GET_SIM_USERINFO,[userid]).then(function(event:SocketEvent):void
                {
                    var userInfo:UserInfo = new UserInfo();
                    UserInfo.setForSimpleInfo(userInfo,event.data as IDataInput);
                    if (fireTypes.indexOf(userInfo.fireBuff) != -1) {
                        SocketConnection.WxCopyFireByUserID(userInfo.userID);
                        d.resolve(true);
                    }
                    else {
                        d.resolve(false);
                    }
                });
                return d.promise;
            };

         // ��������
         ExternalInterface.addCallback("WxSendWithCallback2", function(commandID:int, parameterArray:Array = null):void
         {
            SocketConnection.sendWithCallback2(commandID,
            function(event:SocketEvent):void
            {
                var data:ByteArray = event.data as ByteArray;
                var packet:Array = new Array();
                for (var i:int = 0; i < data.length; i++)
                {
                    packet.push(data.readUnsignedByte());
                }
                SocketConnection.WxCallback(packet);
            }
            ,parameterArray);
         });

         // �Զ����ͼ�ϵ�Ұ�������ս
         SocketConnection.WxOnOgreList = function(e:SocketEvent):void {
            var ba:ByteArray = e.data as ByteArray;
            ba.position = 0;
            for (var i:int = 0; i < 9; ++i) {
                if (ba.readUnsignedInt() == SocketConnection.WxWaitingForOrgeID) { FightManager.fightWithNpc(i); return; }
            }
         }
         ExternalInterface.addCallback("WxAutoFight", function(petID:uint):void
         {
            SocketConnection.removeCmdListener(CommandID.MAP_OGRE_LIST,SocketConnection.WxOnOgreList);
            SocketConnection.WxWaitingForOrgeID = petID;
            SocketConnection.addCmdListener(CommandID.MAP_OGRE_LIST,SocketConnection.WxOnOgreList);
         });

         // ��ȡ�����
         ExternalInterface.addCallback("WxGetActivityValue",function(name:String,key:String):void {
            ActivityHelperManager.getHelper(name).then(function(param1:SimpleHelper):void {
                SocketConnection.WxCallback(param1.getValue(key));
            });
         });

         // ����
         ExternalInterface.addCallback("WxReflSet",function(className:String,path:String,val:*):void {
            var keys:Array = path.split(".");  // ʹ�� `.` �ָ�·��
            var lastKey:String = keys.pop();   // ��ȡ���һ�����Եļ�
            var current:Object = getDefinitionByName(className);
            for each (var key:String in keys) {
                current = current[key]; // ����Ƕ�׵Ķ���
            }
            current[lastKey] = val; // ���ֵ
         });
         ExternalInterface.addCallback("WxReflGet",function(className:String,path:String):* {
            var keys:Array = path.split(".");
            var lastKey:String = keys.pop();
            var current:Object = getDefinitionByName(className);
            for each (var key:String in keys) {
                current = current[key];
            }
            return current[lastKey];
         });
         ExternalInterface.addCallback("WxReflAction",function(className:String,path:String,... rest):void {
            var keys:Array = path.split(".");
            var lastKey:String = keys.pop();
            var current:Object = getDefinitionByName(className);
            for each (var key:String in keys) {
                current = current[key];
            }
            current[lastKey].apply(null,rest);
         });
         ExternalInterface.addCallback("WxReflFunc",function(className:String,path:String,... rest):* {
            var keys:Array = path.split(".");
            var lastKey:String = keys.pop();
            var current:Object = getDefinitionByName(className);
            for each (var key:String in keys) {
                current = current[key];
            }
            return current[lastKey].apply(null,rest);
         });

         setTimeout(function():void {SocketConnection.send(CommandID.NONO_FOLLOW_OR_HOOM,0);},640); // �� nono ���زֿ�

         // �������
         ExternalInterface.addCallback("WxPetFollow",function(id1:uint,ab1:uint,li1:Boolean, id2:uint,ab2:uint,li2:Boolean):void
         {
                if (id1 == 0) {
                    MainManager.actorModel.hidePet();
                    return;
                }
             var info:PetShowInfo = new PetShowInfo();
                info.userID = MainManager.actorID;
                info.catchTime = 160000000;
                info.petID = id1;
                info.isBright = li1;
                info.abilityType = ab1;
                info.flag = 1;
                info.otherPetId = id2;
                info.otherBright = li2;
                info.otherAbilityType = ab2;
                MainManager.actorModel.showPet(info);
         });
         // ����
         ExternalInterface.addCallback("WxScale1",function(sc:Number):void { MainManager.actorModel.scaleX = MainManager.actorModel.scaleY = sc; });
         ExternalInterface.addCallback("WxScale2",function(sc:Number):void { MainManager.actorModel.pet.scaleX = MainManager.actorModel.pet.scaleY = sc; });

         // �۷������
         SocketConnection.WxScreenShot = function() : void
         {
            ExternalInterface.call("seerRandomSkinObj.screenShot");
         }
         SocketConnection.addCmdListener(45144,SocketConnection.WxScreenShot);
      }
   }
}
