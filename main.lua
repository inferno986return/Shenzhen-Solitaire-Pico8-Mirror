-shenzhen solitaire
 --zachtronics (ported by hunterx)
 
 wins = 0;
 windone = false;
 
 cells = {};
 
 selectpos = 9;
 selectdepth = 0;
 selectdrop = false;
 
 grabpos = 1;
 grabdepth = 0;
 
 movetimer = 0;
 movetimermax = 3;
 
 function _init()
     palt(0, false);
     palt(2, true);
     
     cartdata("shenzhen");
     wins = dget(0);
     
     for loop = 1,16 do
         cells[loop] = {};
     end
     
     deck = {};
     deckpos = 9;
     deckdepth = 1;
     for loop = 1,9 do
         add(deck, loop);
         add(deck, loop + 10);
         add(deck, loop + 20);
     end
     for loop = 1,4 do
         add(deck, 0);
         add(deck, 10);
         add(deck, 20);
     end
     add(deck, 30);
     while #deck > 0 do
         index = flr(rnd(#deck)) + 1;
         cells[deckpos][deckdepth] = deck[index];
         del(deck, deck[index]);
         
         if deckpos >= 16 then
             deckpos = 9;
             deckdepth += 1;
         else
             deckpos += 1;
         end
     end
     
     music(0);
 end
 
 function _update()
     if movetimer > 0 then
         movetimer -= 1;
     end
     
     if movetimer == 0 then
         if automove() == true then
             movetimer = movetimermax;
         else
             if btnp(0) == true then
                 oldinv = max(1, #cells[selectpos] - selectdepth);
                 if selectpos == 1 then
                     selectpos = 8;
                 elseif selectpos == 9 then
                     selectpos = 16;
                 else
                     selectpos = selectpos - 1;
                 end
                 if selectdrop == true then
                     selectdepth = 0;
                 else
                     selectdepth = #cells[selectpos] - oldinv;
                     selectdepth = max(0, selectdepth);
                     selectdepth = min(#cells[selectpos], selectdepth);
                 end
             elseif btnp(1) == true then
                 oldinv = max(1, #cells[selectpos] - selectdepth);
                 if selectpos == 8 then
                     selectpos = 1;
                 elseif selectpos == 16 then
                     selectpos = 9;
                 else
                     selectpos = selectpos + 1;
                 end
                 if selectdrop == true then
                     selectdepth = 0;
                 else
                     selectdepth = #cells[selectpos] - oldinv;
                     selectdepth = max(0, selectdepth);
                     selectdepth = min(#cells[selectpos], selectdepth);
                 end
             elseif btnp(2) == true then
                 changepos = false
                 if selectpos == 4 then
                     if selectdepth >= 2 then
                         changepos = true;
                     end
                 else
                     if #cells[selectpos] == 0 then
                         changepos = true;
                     elseif selectdepth >= #cells[selectpos] - 1 then
                         changepos = true;
                     elseif selectdrop == true then
                         changepos = true;
                     end
                 end
             
                 if changepos == true then
                     if selectpos > 8 then
                         selectpos = selectpos - 8;
                     else
                         selectpos = selectpos + 8;
                     end
                     selectdepth = 0;
                 else
                     selectdepth = selectdepth + 1;
                 end
             elseif btnp(3) == true then
                 if selectdepth == 0 then
                     if selectpos > 8 then
                         selectpos = selectpos - 8;
                     else
                         selectpos = selectpos + 8;
                     end
                     if #cells[selectpos] > 0 and selectdrop == false then
                         selectdepth = #cells[selectpos] - 1;
                     elseif selectpos == 4 then
                         selectdepth = 2;
                     else
                         selectdepth = 0;
                     end
                 else
                     selectdepth = selectdepth - 1;
                 end
             elseif btnp(4) == true then
                 if selectpos == 4 then
                     if canmovedragons(selectdepth) == true then
                         movedragons(selectdepth);
                         selectdrop = false;
                         movetimer = movetimermax;
                     end
                 else
                     if selectdrop == true then
                         if candrop(grabpos, grabdepth, selectpos) == true then
                             movecards(grabpos, grabdepth, selectpos);
                             selectdrop = false;
                             movetimer = movetimermax;
                         end
                     else
                         if cangrab(selectpos, selectdepth) == true then
                             grabpos = selectpos;
                             grabdepth = selectdepth;
                             selectdrop = true;
                         end
                     end
                 end
             elseif btnp(5) == true then
                 selectdrop = false;
             end
         end
     end
     
     if haswon() == true and windone == false then
         wins += 1;
         windone = true;
         dset(0, wins);
         music(1);
     end
 end
 
 function _draw()
  map(0, 0, 0, 0, 16, 16);
  print("wins:", 11, 122, 7);
  print(wins, 35, 122, 7);
  
  if canmovedragons(0) then
      spr(56, 48, 16);
  end
  if canmovedragons(1) then
      spr(57, 48, 8);
  end
  if canmovedragons(2) then
      spr(58, 48, 0);
  end
  
  for loop = 1,16 do
      posx = loop;
      posy = 0;
      if loop > 8 then
          posy = 24;
          posx = loop - 8;
      end
      if posy == 0 and posx == 5 then
          posx = 56;
      else
          posx = (posx - 1) * 16;
      end
      
      drawcell(cells[loop], posx, posy);
  end
  
  if selectdrop == true then
      drawselect(grabpos, grabdepth, false);
      if selectpos == 4 then
          drawselectbutton();
      else
          if selectpos <= 8 then
              drawselect(selectpos, selectdepth, true);
          else
              drawselect(selectpos, -grabdepth - 1, true);
          end
      end
  else
      if selectpos == 4 then
          drawselectbutton();
      else
          drawselect(selectpos, selectdepth, false);
      end
  end
 end
 
 function drawcard(cardnum, posx, posy)
     if cardnum == 31 then
         sspr(0, 32, 16, 24, posx, posy);
         return;
     end
 
     sspr(0, 8, 16, 24, posx, posy);
     
     suit = getsuit(cardnum);
     num = getcardnum(cardnum);
     
     if num == 0 then
         sprite = 7;
         if suit == 1 then
             sprite = 23;
         elseif suit == 2 then
             sprite = 39;
         elseif suit == 3 then
             sprite = 55;
         end
         
         spr(sprite, posx, posy);
         spr(sprite, posx + 8, posy + 16, 1, 1, true, true);
     else
         suitcolor = 8;
         sprite = 6;
         if suit == 1 then
             suitcolor = 3;
             sprite = 22;
         elseif suit == 2 then
             suitcolor = 0;
             sprite = 38;
         end
         
         print(num, posx + 3, posy + 3, suitcolor);
         spr(sprite, posx + 4, posy + 8);
         print(num, posx + 10, posy + 16, suitcolor);
     end
 end
 
 function drawcell(cell, posx, posy)
     count = 0;
     for card in all(cell) do
         drawcard(card, posx, posy + (count * 8));
         count = count + 1;
     end
 end
 
 function drawselect(pos, depth, drop)
     spritex = 16;
     spritey = 32;
     if drop == true then
         spritex = 32;
     end
     
     posx = pos;
  posy = 0;
  if posx > 8 then
      posy = 24;
      posx = posx - 8;
  end
  if posy == 0 and posx == 5 then
      posx = 56;
  else
      posx = (posx - 1) * 16;
  end
  
  if #cells[pos] > 0 then
      posy = posy + ((#cells[pos] - max(depth, -1) - 1) * 8);
  end
  
  sspr(spritex, spritey, 16, 8, posx, posy);
  truedepth = depth;
  if truedepth < 0 then
      truedepth = abs(depth) - 1;
  end
  for loop = 0,truedepth do
      posy = posy + 8;
      sspr(spritex, spritey + 8, 16, 8, posx, posy);
  end
  posy = posy + 8;
  sspr(spritex, spritey + 16, 16, 8, posx, posy);
 end
 
 function drawselectbutton()
     sprite = 70;
     if selectdrop == true then
         sprite = 71;
     end
     
     spr(sprite, 48, 16 - (selectdepth * 8));
 end
 
 function getselection(pos, depth)
     output = {};
     for loop = 1,depth+1 do
         index = #cells[pos] - (depth + 1) + loop;
         output[loop] = cells[pos][index];
     end
     return output;
 end
 
 function cangrab(pos, depth)
     selection = getselection(pos, depth);
     lastsuit = -1;
     lastnum = -1;
     first = true;
     
     if #selection == 0 then
         return false;
     elseif pos >= 5 and pos <= 8 then
         return false;
     end
     
     for card in all(selection) do
         suit = getsuit(card);
         num = getcardnum(card);
         if card == 31 then
             return false;
         elseif first == false then
             if suit == lastsuit then
                 return false;
             elseif num == 0 then
                 return false;
             elseif num != lastnum - 1 then
                 return false;
             end
         end
         lastsuit = suit;
         lastnum = num;
         first = false;
     end
     
     return true;
 end
 
 function candrop(grabpos, grabdepth, droppos)
     grabcard = cells[grabpos][#cells[grabpos] - grabdepth];
     if grabcard == nil then
         return false;
     end
 
     if droppos >= 1 and droppos <= 3 then
         if #cells[droppos] == 0 and grabdepth == 0 then
             return true;
         else
             return false;
         end
     elseif droppos >= 4 and droppos <= 5 then
         return false;
     elseif droppos >= 6 and droppos <= 8 then
         if grabdepth == 0 then
             if #cells[droppos] == 0 then
                 if getcardnum(grabcard) == 1 then
                     return true;
                 end
             else
                 dropcard = cells[droppos][#cells[droppos]];
                 if getsuit(grabcard) == getsuit(dropcard)
                 and getcardnum(grabcard) != 0
                 and getcardnum(grabcard) == getcardnum(dropcard) + 1 then
                     return true;
                 end
             end
         end
         return false;
     else
         if #cells[droppos] == 0 then
             return true;
         else
             dropcard = cells[droppos][#cells[droppos]];
             if getsuit(grabcard) != getsuit(dropcard)
             and getcardnum(grabcard) != 0
             and getcardnum(grabcard) == getcardnum(dropcard) - 1 then
                 return true;
             end
         end
         return false;
     end
     return false;
 end
 
 function getsuit(card)
     if card >= 30 then
         return 3;
     elseif card >= 20 then
         return 2;
     elseif card >= 10 then
         return 1;
     else
         return 0;
     end
 end
 
 function getcardnum(card)
     suit = getsuit(card);
     return card - (suit * 10);
 end
 
 function movecards(grabpos, grabdepth, droppos)
     if droppos <= 8 then
         cells[droppos][1] = cells[grabpos][#cells[grabpos]];
         for loop = #cells[grabpos],#cells[grabpos]-grabdepth do
             cells[grabpos][loop] = nil;
         end
     else
         for loop = #cells[grabpos]-grabdepth,#cells[grabpos] do
             add(cells[droppos],cells[grabpos][loop]);
             cells[grabpos][loop] = nil;
         end
     end
     sfx(0, 1);
 end
 
 function canmovedragons(suit)
     count = 0;
     for loop = 1,16 do
         if #cells[loop] > 0 then
             if cells[loop][#cells[loop]] == suit * 10 then
                 count += 1;
             end
         end
     end
     
     if count >= 4 then
         for loop = 1,3 do
             if #cells[loop] == 0 then
                 return true;
             elseif cells[loop][#cells[loop]] == suit * 10 then
                 return true;
             end
         end
         return false;
     else
         return false;
     end
 end
 
 function movedragons(suit)
     moveto = 0;
     
     for loop = 1,3 do
         if #cells[loop] > 0 then
             if cells[loop][#cells[loop]] == suit * 10 then
                 if moveto == 0 then
                     moveto = loop;
                 end
             end
         end
     end
     if moveto == 0 then
         for loop = 1,3 do
             if #cells[loop] == 0 then
                 if moveto == 0 then
                     moveto = loop;
                 end
             end
         end
     end
     
     for loop = 1,16 do
         if #cells[loop] != 0 then
             if cells[loop][#cells[loop]] == suit * 10 then
                 cells[loop][#cells[loop]] = nil;
             end
         end
     end
     
     cells[moveto] = {31};
     sfx(0, 1);
 end
 
 function haswon()
     for loop = 9,16 do
         if #cells[loop] > 0 then
             return false;
         end
     end
     return true;
 end
 
 function automove()
     minfval = -1;
     for loop = 6,8 do
         val = 0;
         if #cells[loop] > 0 then
             card = cells[loop][#cells[loop]];
             val = getcardnum(card);
         end
         if minfval == -1 then
             minfval = val;
         elseif val < minfval then
             minfval = val;
         end
     end
     
     for loop = 1,16 do
         if loop < 4 or loop > 8 then
             if #cells[loop] > 0 then
                 card = cells[loop][#cells[loop]];
                 cardnum = getcardnum(card);
                 suit = getsuit(card);
                 if card == 30 then
                     movecards(loop, 0, 5);
                     return true;
                 elseif cardnum == minfval + 1 and card != 31 then
                     for loop2 = 6,8 do
                         if #cells[loop2] > 0 then
                             card2 = cells[loop2][#cells[loop2]];
                             suit2 = getsuit(card2);
                             if suit2 == suit then
                                 movecards(loop, 0, loop2);
                                 return true;
                             end
                         end
                     end
                     for loop2 = 6,8 do
                      if #cells[loop2] == 0 then
                          movecards(loop, 0, loop2);
                          return true;
                      end
                     end
                 end
             end
         end
     end
     
     return false;
 end
