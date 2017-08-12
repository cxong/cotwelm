module Game.Loot exposing (..)

import Item
import Item.Data exposing (..)
import Item.Weapon
import Item.Wearable
import Random.Pcg as Random exposing (Generator)


{-| Loot is random items that can appear:

1.  After killing a monster
2.  Lying on the ground in the dungeon
3.  Within some container (which is also loot) that's lying on the ground in the dungeon

-}
type alias Loot =
    List Item


generate : Generator Loot
generate =
    Random.frequency
        [ ( 1, coinLoot 30 20 )
        , ( 1, weaponLoot Item.Weapon.listTypes )
        , ( 1, armourLoot Item.Wearable.armourTypes )
        ]
        |> Random.map (flip (::) [])


{-| Given a average number of coins, generate any number between (avg - range) to (avg + range)
-}
coinLoot : Int -> Int -> Generator Item
coinLoot average range =
    let
        coinTypeGenerator =
            Random.sample [ ItemTypeCopper, ItemTypeSilver, ItemTypeGold, ItemTypePlatinum ]
                |> Random.map (Maybe.withDefault ItemTypeCopper)

        ( minCoins, maxCoins ) =
            ( max 0 (average - range), average + range )

        coinQuantityGenerator =
            Random.int minCoins maxCoins

        makeCoins coinType coinQuantity =
            Item.new (coinType coinQuantity)
    in
    Random.map2 makeCoins coinTypeGenerator coinQuantityGenerator


weaponLoot : List WeaponType -> Generator Item
weaponLoot =
    Random.sample
        >> Random.map (Maybe.withDefault Dagger)
        >> Random.map ItemTypeWeapon
        >> Random.map Item.new


armourLoot : List ArmourType -> Generator Item
armourLoot =
    Random.sample
        >> Random.map (Maybe.withDefault LeatherArmour)
        >> Random.map ItemTypeArmour
        >> Random.map Item.new
