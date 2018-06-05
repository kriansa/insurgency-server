## SourceMod upgrade

1. Keep file `sourcemod/gamedata/insurgency.games.txt`
2. Keep file `sourcemod/configs/admins.cfg`
3. Keep file `sourcemod/configs/core.cfg`
4. Keep folder `sourcemod/scripting/custom`
5. Disable the following plugins (move them to the `disabled` folder):
   - basevotes.smx
   - funcommands.smx
   - funvotes.smx
   - nextmap.smx
6. Recompile plugins (run `compile-plugins`)
7. Remove `metamod_x64.vdf`
8. Update file `VERSIONS`
