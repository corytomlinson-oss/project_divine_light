# project_divine_light
Prompt 1
Hello I recently picked up a Retroid Pocket 6. I would like to design a game for it. I would like you to help me come up with a Story, design document, Feature list, and finally help code it. 
I have never done android development before and do not know what tools I need. Is this something you can help with and help guide me through the process? 

Prompt 2
A couple questions before we begin. I use Visual Code for development. 
Am I able to do Godot development in Visual Code. I really want to make a retro rpg in the vain of the original Final Fantasy. 
I want to make it turn based and class based. Is this a good matchup for Godot? 

Prompt 3
I would like High Fantasy. My high level story idea is there are a set of super natural characters that get born into the world (ie their character class). Some turn evil, some turn good. 
Some sickness in the world has been making these character always turn evil. There are only 4 good ones left (including yourself). 
You start by trying free the other good ones from bosses to form your party (beginning of the game). 
Work on saving the kingdom/country and removing the virus/evil characters (mid game), 
and then you destroy the evil source to restore balance to the world 

Prompt 4
Yes I would like to create a unique classes for the 4. One of them I would like to be a Martial artist (Fighter) and Invoker (wizard). Maybe a Templar for the Cleric role and Assassin for the Thief Role? 


Current output
Development Handover & Progress Document

This document serves as the project state and memory bank for our retro high-fantasy RPG developed specifically for the Retroid Pocket 6 (Android 13, Snapdragon 8 Gen 2, 120Hz AMOLED, hardware controller inputs).  

Keep this file intact to quickly restore the development context when resuming work.  
🌌 Project Vision & Narrative Archetype

    Genre: 2D Grid-Based Retro RPG (Turn-Based & Class-Based).  

    Inspiration: Original Final Fantasy (NES/GBA era).  

    Core Conflict: Universal forces and classes are cyclically reborn into the world to preserve balance. A cosmic "Virus/Sickness" has infected this cycle, causing newly awakened entities to turn instantly evil.  

    The Protagonist & Goal: You awaken as the first uncorrupted entity. Only 4 pure entities remain uninfected in the entire world.  

    Act I (The Gathering): Track down, fight, and "cleanse" the remaining three pure entities who are trapped or mind-controlled by corrupted elites inside localized dungeons. Defeating them clears the corruption and recruits them to your active party.  

    Act II (The Purge): Journey across kingdoms to defeat fully corrupted elite classes and liberate subjugated towns.  

    Act III (The Source): Descend into the epicentre of the cosmic virus to destroy the corruption at its root, permanently restoring the balance of reincarnation.  

🛡️ Character & Class Architecture

The party consists of four highly distinct, modernized versions of classic RPG archetypes.  

    The Templar (Protector / Healer)

        Role: Frontline tank, damage mitigation, holy/divine magic restoration.  

        Primary Stats: High Max HP, High Defense.  

    The Martial Artist (Physical Brawler)

        Role: High-speed close combat fighter using fists/claws.  

        Primary Stats: High Strength, potentially uses a custom "Qi" or combo mechanic rather than traditional MP.  

    The Invoker (Elemental Wizard)

        Role: Versatile backline magic user who channels or summons cosmic/environmental elements dynamically to alter active spellkits.  

        Primary Stats: High Intelligence, High Max MP.  

    The Assassin (Agility / Status Striker)

        Role: High crit-rate damage dealer, inflicts debilitating ailments (poison, bleeding, stuns).  

        Primary Stats: High Agility (determines turn-order priority).  

🛠️ Technical Setup & Engine Architecture
Tooling Specs

    Engine: Godot 4 (Standard Edition / GDScript).  

    Target Build Target: Android API 33+ (Native deployment via Android SDK to APK).  

    IDE / Script Editor: Visual Studio Code (VS Code) utilizing the official Godot Tools extension.
