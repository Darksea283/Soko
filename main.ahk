SetBatchLines,-1
#InstallKeybdHook

;~ #################################################################################################
;~ ####################################    Building GUI    #########################################

Menu, FileMenu, Add, Start    , Start      
Menu, FileMenu, Add, Select File  , SelectFile      
Menu, HelpMenu, Add, About      , About    

Menu,MenuBar,Add,File, :FileMenu
Menu,MenuBar,Add,Info, :HelpMenu

Gui,Menu,Menubar

Gui,Add,Button,x0 y0 w50 gRestart,Restart

Row := "20"
loop,30
{
  Line := a_index * 20
  LineNum := A_Index

  loop,50
  {
    Row := a_index * 20
    VarName := "L" . LineNum . "R" . a_index
    Gui,Add,Picture,x%Row% y%Line% w20 h20 v%VarName%,%a_scriptdir%\Data\floor.jpg
  }
  
}
gui,show,x0 y0 h650 w1200
gui,+resize
return
;~ #################################################################################################
;~ ########################################   MAINLOOP     #########################################

Start:
if ( Filepath == "" )
  Fileread,LevelData,*t %a_scriptdir%\Data\Level.xsb
else
  Fileread,LevelData,*t %FilePath%


CurrentLevel := "1"
NextLevel := "1"
loop,
{
  If ( NextLevel ) {
    Level :=new Level(CurrentLevel,LevelData)
    NextLevel := "0"
  }
  
  if ( Key != "" ) {
    worldObjects.Move(Key)
    Key=
  }
  
  if ( worldObjects.Update() = "victory" ) {
    msgbox,GREATU SUCCESSU!!!
    NextLevel++
    CurrentLevel++
  }
  sleep,20
} ; Gameloop
return

;~ #################################################################################################
;~ ############################################ Classes          ###################################


Class Level
{
  __new(CurrentLevel,LevelData) {
    
    this.GetLevelData(CurrentLevel,LevelData)
    
    this.BuildLevel(this.LevelCont)
    ;~ msgbox,"%NewStructure%"
  }
  
  GetLevelData(CurrentLevel,LevelData) {
    ; Cuts out the level from the LevelData based on the levelnumber

    if ( Instr(LevelData,SearchStr) >= 1 )
      StringTrimLeft,LevelStructure,LevelData,% Instr(LevelData,"; " . CurrentLevel)
    else
      LevelStructure := LevelData
    

    
    if ( Instr(LevelStructure,";") > 1 )
      Stringleft,LevelStructure,LevelStructure,% Instr(LevelStructure,";")-1
    

    
    ; Cut out semicolon line and empty lines
    loop,parse,LevelStructure,`n
    {
      if ( a_loopfield != "" && Instr(a_loopfield,";") == 0 )
        NewStructure .= A_LoopField . "`n"
    }
    
    this.LevelCont := NewStructure
  }
  
  BuildLevel(LevelCont) {
    Line = 1
    Row = 1
    
    global WorldObjects := new worldObjectbase
    
    loop,parse,LevelCont
    {
      if ( a_loopfield == "`n" ) {
        Line++
        Row = 1
        continue
      }
      
      VarName := "L" . Line . "R" . Row
      
      if ( a_loopfield = a_space ) {
        Guicontrol,,%VarName%,%a_scriptdir%\Data\floor.jpg
        this.insert(new valuePair(VarName,"floor"))
      }
      if ( a_loopfield = "#" ) {
        Guicontrol,,%VarName%,%a_scriptdir%\Data\wall.jpg
        this.insert(new valuePair(VarName,"wall"))
      }
      if ( a_loopfield = "@" ) {
        Guicontrol,,%VarName%,%a_scriptdir%\Data\player.jpg
        WorldObjects.Add(VarName,"player")
        this.insert(new valuePair(VarName,"floor"))
      }
      if ( a_loopfield = "$" ) {
        Guicontrol,,%VarName%,%a_scriptdir%\Data\ball.jpg
        WorldObjects.Add(VarName,"Ball")
        this.insert(new valuePair(VarName,"floor"))
      }
      if ( a_loopfield = "." ) {
        Guicontrol,,%VarName%,%a_scriptdir%\Data\goal.jpg
        ;~ WorldObjects.Add(VarName,"goal")
        this.insert(new valuePair(VarName,"goal"))
      }
      Row++
    }
  }
  
  ; sets the tile to its empty state
  emptyTile(Loc) {
    for k,item in this {
      ;~ msgbox,% loc . "`n" . item.Loc . "`n" . item.type
    
      if ( item.Loc == Loc ) {
        type := item.type
        ;~ msgbox,% type
        Guicontrol,,%loc%,%a_scriptdir%\Data\%type%.jpg
        return
      }
    }
  }
  
  ; gets the type of the tile
  getTile(Loc) {
    for each, item in this {
      if (item.Loc == loc )
        return item.type
    }
  }
}

class worldObjectbase
{
  
  ; adds the data object to this object
  add(Loc,type) {
    this.Insert(new valuePair(Loc,type))
  }
  
  ; updates the level based on the objects
  update() {
    for k, item in this {
      if ( item.type = "ball" ) {
        if ( level.getTile(item.loc) = "goal" )
          Goal++
        else
          goal = 0
      }
      
      if ( item.OldLoc != item.Loc ) {
        filename := item.type
        controlname := item.Loc
        Guicontrol,,%controlname%,%a_scriptdir%\data\%filename%.jpg
        item.OldLoc := item.Loc
      }
    }
    
    if ( goal > 0 )
      return "victory"
  }
  
  ; moves the player and the balls
  move(Dir,obj = "") {
    
    if ( !isObject(obj) ) {
      for each, item in this {
        if ( item.type = "player" ) {
          obj:=item
        }
      }
    }
    
    for k,item in this {
        ;~ msgbox,% item.type
    
      if ( item.type == obj.type && item.Loc == obj.Loc ) {
        
        OldLoc := item.Loc
        Loc := item.Loc
        
        if ( Dir == "right" ) {
          Stringmid,row,Loc,% instr(Loc,"R")+1
          newRow := row+1
          StringReplace,Loc,Loc,R%row%,R%newrow%
        }        
        
        if ( Dir == "left" ) {
          Stringmid,row,Loc,% instr(Loc,"R")+1
          newRow := row-1
          StringReplace,Loc,Loc,R%row%,R%newrow%
        }        
        
        if ( Dir == "up" ) {
          Stringmid,line,Loc,2,% instr(Loc,"R")-2
          newline := line-1
          StringReplace,Loc,Loc,L%line%,L%newline%
        }        
        
        if ( Dir == "down" ) {
          Stringmid,line,Loc,2,% instr(Loc,"R")-2
          newLine := line+1
          StringReplace,Loc,Loc,L%line%,L%newline%
        }
        
        ;~ msgbox,% item.type
        
        if ( Level.getTile(Loc) = "wall" )
          return "wall"
        
        PushObj := this.getObject(loc)
        
        ;~ msgbox,% PushObj.type . "`n" . item.type
        
        if ( item.type = "ball" && PushObj.type = "ball" )
          return "wall"
        
        if ( PushObj.type = "ball" ) {
          WallCheck := this.move(Dir,PushObj)
          if (  WallCheck = "wall" )
            return wall
        }
        
        item.Loc := Loc
        Level.EmptyTile(OldLoc)
      }
    }
  }
  
  ; gets the datapair object based on the location
  getObject(Loc) {
    for each, item in this {
      if ( item.Loc == Loc ) {
        return item
      }
    }    
  }
}

; data object
class valuePair 
{
  __new(Loc,type) {
    this.Loc := Loc
    this.type := type
  }
}
;~ #################################################################################################
;~ #########################################     HotKeys    ########################################


SelectFile:
FileSelectFile,FilePath
return

About:

return

Escape::
GuiClose:
Exitapp

up::
Key:="up"
return
down::
Key:="down"
return
right::
Key:="right"
return
left::
Key:="left"
return

restart:
nextlevel = 1
return