# Client patches

Each folder here is a patched game client. It contains only the ActionScript
classes that differ from the original SWF, decompiled with
[JPEXS FFDec](https://github.com/jindrapetrik/jpexs-decompiler) and edited.

`tools/build_client.py` compiles them into a copy of the original SWF in
`assets/flash/`, which is then selectable on the login page. Graphics that
only exist in other game versions are first copied in with
`tools/SwfTransplant.java` (listed under `symbols` in the build script).

```
python tools/build_client.py --ffdec path/to/ffdec-cli.jar
```

It needs a JDK and FFDec's `lib` folder next to the jar. FFDec's compiler only
catches syntax errors: a misspelled method or property compiles and fails when
the game runs, so check new names against the decompiled sources.

To change a class that is not here yet, export it from the original SWF with
FFDec, commit it unmodified first, then edit it. That way the history shows
exactly what the patch changes.

## 1.0.0-se

Based on 0.9.26b (`SocialEmpires0926bsec.swf`), built as
`SocialEmpires1.0.0-sesec.swf`.

- **Hover collect** (from 1.1.5): resource and XP drops are collected by moving
  the mouse over them instead of clicking. `core/Token.as`
- **Unit training queue** (inspired by 1.1.5): buildings queue up to 5 units
  instead of one. Each unit is paid when queued, and the progress bar shows how
  many are waiting (`45% +2`). Units with a limit (heroes, etc.) are not
  queued. As in 0.9.26b, units still in training are not saved: reloading
  drops them and the server never charges for them.
  `core/isoengine/IsoBuilding.as`, `core/FauxBar3.as`
- **Training panel** (from 1.1.5): the town hall, castle, barracks, archery,
  stable, workshop and church use the 1.1.5 panel (`EP_NewBarracksMC`, copied
  from `SocialEmpires1.1.5sec.swf`). It shows the unit's cost and training
  time, a countdown over the unit being trained, and the queue in five slots;
  clicking a slot cancels the last unit in the queue and refunds it. Move,
  rotate and store are in the tools menu. The 1.1.5 speed up bar trains the
  unit with cash instead, since training here takes seconds.
  `GUI/RecuadroInfo.as`, labels in `config/patch/training_panel_strings.json`
- **Unit collections count**: buying a unit from the Collections menu counts
  it right away (0.9.26b only counted it after a reload).
  `popups/PopupAllUnits.as`
- **Sell all from storage**: selling an item with more than one copy asks
  whether to sell all of them (Yes) or only one (No). Cash items still ask
  to confirm selling for 0 cash. `GUI/GiftButtonLarge.as`, `GUI/GiftWindow.as`
- **Keyboard shortcuts**: Tab / Shift+Tab select the next / previous unit
  among the special units shown above the panel (wrapping around), 1-4 use
  the selected unit's skills and R its limit. Tab no longer moves the focus
  between buttons. Shortcuts are off while typing in a text field.
  `GUI/RecuadroInfo.as`
- **Skill overlays**: the selected special unit gets a white border in the
  row above the panel, skills show their shortcut (1-4, R) in the bottom
  left corner, and the seconds left until the unit can use a skill again
  while it is casting or cooling down. `GUI/PortraitSpecialAttack.as`,
  `GUI/RecuadroInfo.as`
