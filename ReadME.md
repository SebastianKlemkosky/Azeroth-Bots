# Azeroth Bots

**Azeroth Bots** is an experimental autonomous-agent project built on **AzerothCore** and **Playerbots**.

The goal is to create a living World of Warcraft simulation where hundreds of bots move through Azeroth, level, fight, explore, group together, complete dungeons, acquire equipment, and eventually attempt raids.

The human player does not primarily control a single character.

**The human is the Overseer.**

The Overseer watches the bot population, studies individual characters, gives them goals, influences their environment, intervenes when desired, and observes how their behavior develops over time.

The long-term challenge is simple:

> **Can a population of autonomous World of Warcraft bots eventually organize, progress, and successfully clear raid content?**

---

# Project Vision

Azeroth Bots is intended to be more than a collection of scripted WoW characters.

The project will combine:

* AzerothCore as the simulated game world
* Playerbots as the baseline autonomous agents
* A custom controller for bot objectives and world interaction
* Telemetry and character-history tracking
* An Overseer dashboard
* Dungeon and raid experimentation
* Optional hardcore-style rules
* Iterative improvements to bot behavior

Bots should continue living in the world even when the Overseer does nothing.

The Overseer can simply watch them or choose to influence what happens.

---

# The Overseer

The Overseer represents the human's role in the simulation.

Instead of manually playing every bot, the Overseer operates at a higher level.

## Observe

The Overseer should eventually be able to see:

* Bot locations
* Current zones
* Levels
* Classes and roles
* Health and mana
* Current activities
* Current goals
* Groups
* Equipment
* Deaths
* Dungeon activity
* Raid activity
* Character history
* Population statistics

A world map should eventually show bots moving throughout Azeroth in real time.

---

## Direct

The Overseer should be able to assign high-level goals.

Examples:

* Travel to Westfall
* Reach level 20
* Form a five-player group
* Find a healer
* Enter Deadmines
* Clear a dungeon
* Acquire better equipment
* Prepare for a raid
* Attempt Molten Core

The goal is not to manually control every spell or movement.

The Overseer defines **what should be accomplished**, while the bots determine how to accomplish it whenever possible.

---

## Influence

The Overseer may influence behavior without directly commanding a bot.

Examples:

* Place treasure in an area
* Increase the reward for an objective
* Provide useful equipment
* Create opportunities
* Encourage exploration
* Create environmental challenges

This allows experiments such as:

> What happens if a valuable chest appears in a remote location?

or:

> Will bots repeatedly travel through a dangerous area, find another path, or eventually organize enough strength to survive it?

---

# God Tools

The Overseer should eventually have direct world-manipulation tools.

Possible tools include:

## Character Controls

* Give item
* Give gold
* Give experience
* Heal
* Resurrect
* Teleport
* Change destination
* Assign objective
* Inspect AI state
* Inspect inventory
* Inspect equipment

## Group Controls

* Create group
* Assign leader
* Assign tank
* Assign healer
* Assign DPS
* Set destination
* Set objective
* Disband group

## World Controls

* Spawn creature
* Spawn boss
* Spawn chest
* Spawn item
* Spawn resource
* Create temporary event
* Modify an area
* Teleport characters

Every Overseer intervention should be logged so later analysis can distinguish autonomous accomplishments from human-assisted ones.

---

# Character Histories

Every bot should develop a persistent history.

The Overseer should be able to search for any character and inspect that character's life.

Example:

```text
Thorgar
Orc Warrior
Level 37
Status: Alive

12:41 PM  Reached level 37
11:58 AM  Entered Stranglethorn Vale
11:32 AM  Acquired Whirlwind Axe
10:47 AM  Completed Scarlet Monastery: Armory
10:43 AM  Defeated Herod
10:10 AM  Joined SM Group 4
 9:21 AM  Reached level 36
 8:52 AM  Died to Venture Co. Mercenary
```

---

# Telemetry

A custom telemetry system will record important events produced by bots and the Overseer.

Initial event categories should include:

## Progression

* Character created
* Level gained
* Experience milestones
* Maximum level reached

## Movement

* Zone entered
* Area discovered
* Dungeon entered
* Raid entered
* Major travel events

## Combat

* Death
* Killer
* Elite kill
* Boss kill
* Group wipe
* Combat encounter

## Equipment

* Important item acquired
* Item equipped
* Rare item acquired
* Epic item acquired
* Major upgrade

## Groups

* Joined group
* Left group
* Became leader
* Role assigned
* Group created
* Group disbanded

## Dungeons

* Dungeon entered
* Boss attempted
* Boss defeated
* Party wipe
* Dungeon completed

## Raids

* Raid created
* Raid entered
* Boss attempted
* Boss defeated
* Raid wipe
* Raid completed

## Overseer Actions

* Item granted
* Gold granted
* Experience granted
* Character teleported
* Character resurrected
* Chest spawned
* Creature spawned
* Goal changed
* Other intervention

## Objectives

* Objective assigned
* Objective started
* Objective completed
* Objective failed
* Objective abandoned

---

# Milestones

Raw telemetry events will be used to generate character milestones.

Examples:

* Reached level 10
* Reached level 20
* Reached level 40
* Reached level 60
* First death
* Tenth death
* First rare item
* First epic item
* First dungeon
* First dungeon boss kill
* First dungeon completion
* First raid
* First raid boss kill
* First raid completion

Custom milestones could eventually include:

* Survived 10 hours without dying
* Completed five dungeons without Overseer intervention
* Reached maximum level without assistance
* Survived to maximum level under hardcore rules
* First character to defeat a specific boss
* First bot raid to defeat Ragnaros

---

# Experiments

A major purpose of Azeroth Bots is running repeatable experiments.

An experiment could be:

```text
Objective:
Clear Deadmines

Party:
5 bots

Rules:
No Overseer intervention

Attempt:
12

Result:
Failure

Progress:
83%

Cause:
Tank death

Observations:
Healer still had 74% mana.
Healer was too far from the tank.
Tank pulled additional enemies.
DPS continued attacking instead of disengaging.
```

The behavior can then be changed and the experiment repeated.

The development loop becomes:

```text
Observe
   ↓
Identify Failure
   ↓
Modify Behavior
   ↓
Run Again
   ↓
Compare Results
```

---

# Dungeon Progression

Raids are the long-term objective, but bots must first demonstrate smaller capabilities.

Expected progression:

```text
World Survival
      ↓
Leveling
      ↓
Navigation
      ↓
Grouping
      ↓
Class Roles
      ↓
Combat Coordination
      ↓
Dungeon Entry
      ↓
Dungeon Completion
      ↓
Gear Progression
      ↓
Raid Preparation
      ↓
Raid Coordination
      ↓
Raid Completion
```

An early major milestone will be:

> **Five bots independently form a viable group and complete a dungeon with minimal or no Overseer intervention.**

---

# Raid Goal

Raids are the project's primary long-term benchmark.

Eventually the system should be capable of tracking something similar to:

```text
Molten Core Experiment #38

Raid Size: 40

Bosses Defeated:
5 / 10

Characters Alive:
26 / 40

Deaths:
14

Current Failure:
Baron Geddon

Observed Problem:
Bots affected by Living Bomb failed to separate from the raid.
```

The system can then identify the behavior responsible for the failure and allow another strategy to be tested.

The eventual objective is:

> **Guide and improve a bot population until an autonomous raid group is capable of clearing raid content.**

---

# Hardcore Mode

A later experimental mode will introduce hardcore-style rules.

Possible rules:

* A character death is permanent for the experiment.
* Dead characters cannot participate again.
* Raid teams must replace lost members.
* Character histories remain permanently recorded.
* Overseer intervention can be restricted or disabled.
* Assisted and unassisted accomplishments are tracked separately.

This turns character survival and population management into part of the experiment.

---

# Architecture

The project will eventually consist of several layers.

```text
                 AZEROTH OVERSEER
                        │
                        │
               Controller / API
                        │
          ┌─────────────┴─────────────┐
          │                           │
      Telemetry                  Commands
          │                           │
          │                           │
   Character History            AzerothCore
   Experiments                       │
   Analytics                         │
                               Playerbots
                                    │
                                    │
                                Azeroth
```

---

# AzerothCore

AzerothCore provides:

* World simulation
* Characters
* Creatures
* Combat
* Quests
* Items
* Dungeons
* Raids
* Networking
* Game databases

The AzerothCore source tree is intentionally kept separate from the custom project code.

---

# Playerbots

Playerbots currently provides the baseline bot intelligence.

Initially, Azeroth Bots will use existing Playerbots behavior wherever possible.

Over time, behavior may be:

* Configured
* Extended
* Overridden
* Replaced
* Experimentally modified

Machine learning is **not required** for the project.

Rules, planners, behavior systems, scripted strategies, Playerbots AI, and other techniques can all be explored.

---

# Controller

The custom controller will sit between the Overseer and AzerothCore.

Its responsibilities will eventually include:

* Sending commands
* Creating objectives
* Managing experiments
* Querying character state
* Collecting telemetry
* Tracking milestones
* Recording Overseer interventions
* Managing groups
* Monitoring dungeon attempts
* Monitoring raid attempts

AzerothCore SOAP command access is already working and provides the first communication mechanism for the controller.

---

# Telemetry Database

Experiment and character-history data should remain separate from AzerothCore's primary game databases.

Initial implementation:

```text
data/
└── overseer.db
```

SQLite is a suitable starting point.

Potential tables:

```text
characters
events
milestones
objectives
groups
experiments
experiment_runs
overseer_actions
```

The telemetry layer can be migrated to a larger database later if necessary.

---

# Overseer Dashboard

The eventual dashboard could include:

```text
--------------------------------------------------------
                    AZEROTH OVERSEER
--------------------------------------------------------

Population
500 Bots

Alive
487

Groups
37

Dungeon Groups
4

Raid Groups
0

Active Objectives
19

--------------------------------------------------------
WORLD MAP
--------------------------------------------------------

             [ Live Bot Positions ]

--------------------------------------------------------
SELECTED CHARACTER
--------------------------------------------------------

Thorgar
Level 37 Orc Warrior

Location:
Stranglethorn Vale

Activity:
Fighting Venture Co. enemies

Goal:
Reach Level 40

Group:
None

[ History ]
[ Give Goal ]
[ Teleport ]
[ Give Item ]
[ Spawn Chest ]
[ Inspect AI ]

--------------------------------------------------------
```

---

# Current Working State

The base AzerothCore environment is operational.

Currently working:

* AzerothCore Playerbot branch
* mod-playerbots
* MySQL
* AzerothCore world database
* AzerothCore authentication server
* AzerothCore world server
* WoW 3.3.5a client connection
* 500 random Playerbots
* Local SOAP administration
* Automated server startup
* Automated clean shutdown
* Automated restart
* Automated server status checks
* Automated AzerothCore rebuild
* Centralized environment configuration

A known-good server state currently contains:

```text
Connected real players: 0
Characters in world: 500
```

---

# Server Management

The main management utility is:

```text
Server-Tools\Azeroth-Bots.bat
```

Current options:

```text
1. Start Server
2. Stop Server
3. Restart Server
4. Server Status
5. Open Configs
6. Rebuild AzerothCore
7. Open Project Folder
8. Open Runtime Folder
9. Exit
```

Shared environment configuration is stored in:

```text
Server-Tools\server-env.bat
```

SOAP commands are sent through:

```text
Server-Tools\Send-AcoreCommand.ps1
```

Credentials must remain outside Git.

---

# Development Roadmap

## Phase 1 — Infrastructure

**Status: Mostly Complete**

* [x] Install AzerothCore
* [x] Compile Playerbot branch
* [x] Install mod-playerbots
* [x] Configure MySQL
* [x] Configure WoW 3.3.5a client
* [x] Connect remotely over LAN
* [x] Run 500 random bots
* [x] Enable SOAP
* [x] Send commands programmatically
* [x] Create Start script
* [x] Create Stop script
* [x] Create Restart script
* [x] Create Status script
* [x] Create Rebuild script
* [x] Create server management menu

---

## Phase 2 — Bot Observation

Build the first custom Azeroth Bots component.

* [ ] Identify useful Playerbots state
* [ ] Read character information
* [ ] Track bot locations
* [ ] Track levels
* [ ] Track deaths
* [ ] Track group membership
* [ ] Track equipment changes
* [ ] Track dungeon activity
* [ ] Store events in telemetry database
* [ ] Search character history
* [ ] Generate milestones

### First Goal

Be able to select a bot and answer:

> **What has this character been doing?**

---

## Phase 3 — Objectives and Control

* [ ] Discover Playerbots command system
* [ ] Send commands through the controller
* [ ] Select individual bot
* [ ] Select group
* [ ] Assign destination
* [ ] Assign objective
* [ ] Create groups
* [ ] Assign roles
* [ ] Track objective completion
* [ ] Track objective failure

### Goal

Tell bots what should happen without manually controlling every action.

---

## Phase 4 — Overseer Interface

* [ ] Build dashboard
* [ ] Character search
* [ ] Character profile
* [ ] Character timeline
* [ ] World population view
* [ ] Live map
* [ ] Group view
* [ ] Objective view
* [ ] Intervention controls
* [ ] Experiment controls

---

## Phase 5 — God Tools

* [ ] Give item
* [ ] Give gold
* [ ] Give XP
* [ ] Teleport character
* [ ] Resurrect character
* [ ] Spawn creature
* [ ] Spawn chest
* [ ] Create environmental event
* [ ] Log all Overseer interventions

---

## Phase 6 — Dungeon Experiments

* [ ] Create balanced five-player party
* [ ] Assign tank
* [ ] Assign healer
* [ ] Assign DPS
* [ ] Travel to dungeon
* [ ] Enter dungeon
* [ ] Track pulls
* [ ] Track deaths
* [ ] Track wipes
* [ ] Track bosses
* [ ] Record completion percentage
* [ ] Complete first autonomous dungeon

---

## Phase 7 — Raid Experiments

* [ ] Create raid group
* [ ] Assign raid roles
* [ ] Track raid preparation
* [ ] Track consumables
* [ ] Track equipment
* [ ] Track boss attempts
* [ ] Track individual deaths
* [ ] Track wipes
* [ ] Analyze failure causes
* [ ] Modify strategies
* [ ] Repeat experiments

### Ultimate Goal

> **A bot-controlled raid defeats a raid using behavior developed and improved through repeated experimentation.**

---

## Phase 8 — Hardcore Azeroth

* [ ] Permanent experimental deaths
* [ ] Character lineage/history
* [ ] Survivor tracking
* [ ] Replacement recruitment
* [ ] Population attrition
* [ ] Hardcore dungeon progression
* [ ] Hardcore raid progression
* [ ] Minimal-intervention experiments

---

# Project Principles

## Bots Should Have Agency

The Overseer defines objectives.

Bots should determine lower-level actions whenever possible.

---

## Intervention Is Part of the Experiment

Helping a bot is allowed.

The system simply records that assistance occurred.

This lets assisted and autonomous accomplishments be compared.

---

## Observe Before Replacing

Playerbots already contains substantial AI.

Existing behavior should be observed and measured before custom behavior replaces it.

---

## Every Failure Is Data

A wipe is not simply a failed attempt.

It provides information about:

* Positioning
* Aggro
* Healing
* Target selection
* Movement
* Group composition
* Equipment
* Strategy

Failures should be recorded and analyzed.

---

## Build Incrementally

Do not begin by trying to automate a 40-player raid.

First make one bot observable.

Then controllable.

Then create a group.

Then complete a dungeon.

Then progress toward raids.

---

# Immediate Next Steps

The infrastructure phase is complete enough to begin developing Azeroth Bots itself.

The next work should be:

1. Investigate the current Playerbots command and data interfaces.
2. Determine how to retrieve character state programmatically.
3. Create the initial telemetry database.
4. Record basic character events.
5. Track level milestones and deaths.
6. Build a character-history query.
7. Begin tracking bot locations.
8. Create the first controlled bot party.
9. Begin connecting these systems to the Overseer.

The first custom feature should be:

> **Search for a character and view that character's history and milestones.**

From there, the project can expand into live observation, bot objectives, world intervention, dungeon experiments, and eventually raids.
