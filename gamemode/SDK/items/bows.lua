local ITEM = items.RegisterClass("Flimsy Bow")
ITEM.UseDelay = 1.2
ITEM.Icon = "darkland/rpg/items/flimsybow"
ITEM.Range = 600
ITEM.BaseDamage = {3,5}
ITEM.WeaponType = WEAPON_BOW
ITEM.Effect = "FlameArrow" --TODO
ITEM.WeaponModel = "models/darkland/rpg/weapons/ranged/bow.mdl"

ITEM.Description = "A flimsy bow with a short arrow range"
ITEM.Weight = 7
ITEM.TwoHanded = true
ITEM.EquipAt = "Weapon"
ITEM.NoBar = true --no binding to quick bar
ITEM.Category = "Weapon"