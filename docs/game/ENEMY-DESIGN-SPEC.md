# Enemy Design Spec

## Combat Thesis

`Killer Queen` should not ask the player to pick one forever-safe weapon and ignore the other.

The right rule is:

- `Arc Cutter` wins space through commitment, rebound, and kill momentum.
- `Blaster` wins space through reach, weak-point checks, and lane opening.
- The best enemies let each mode solve a different part of the problem.

That keeps melee as the fantasy anchor while preserving the sword/gun swap as a real decision.

## Weapon Jobs

### Arc Cutter

- close-range burst answer
- best finish tool
- best answer to exposed cores, clustered bugs, and rebound routes
- should pay back with altitude, pop, or forward momentum

### Blaster

- safe opener
- weak-point checker
- best answer to hovering targets before commit
- best answer to mines, pods, or shutters the player should not body-check immediately

## Enemy Roster

### 1. `Mite Drifter`

Role:
- small hovering bug that patrols air lanes in pairs or trios

Why blade is good:
- Rising Slash or an air cleave should cut through the cluster fast
- blade kills should give the cleanest upward pop in the early game

Why gun is good:
- the blaster can thin a flock before the player commits
- good for protecting a recovery line when the player is low on fuel or out of position

Stage use:
- `Hive Shaft`
- `Sunset Ruin Skyline`

Design rule:
- fragile body
- very readable drift path
- dies loudly and instantly

### 2. `Shellback Crawler`

Role:
- grounded beetle with a frontal shell plate and exposed rear vent

Why blade is good:
- Dash Slash or a flank cut should crack the shell and launch the player forward
- once opened, the player should want to finish it with melee for momentum

Why gun is good:
- the blaster can ping the rear vent or force a turn from safety
- useful when the terrain is too tight for a clean melee flank

Stage use:
- `Overgrown Foundry`
- `Flooded Transit`

Design rule:
- strong silhouette
- shell clearly readable from the walkable side
- never just a contact-damage wall

### 3. `Lancer Wasp`

Role:
- aggressive flying interceptor with a telegraphed stab dash

Why blade is good:
- best answer is to cut into the lunge window and win the exchange
- blade kill should feel like a heroic interception

Why gun is good:
- blaster shots can stagger the charge early or clean up a bad spacing read
- gives less reward than the melee answer, but stabilizes pressure

Stage use:
- `Sunset Ruin Skyline`
- `Queen's Core`

Design rule:
- obvious windup
- sharp lane attack
- generous hurt window after the miss

### 4. `Brood Pod`

Role:
- stationary nest growth that spits mites or contaminates a route if ignored

Why blade is good:
- close cut should burst the pod and clear nearby hatchlings
- a committed melee destroy should read like “I ripped the nest open”

Why gun is good:
- blaster can safely pop pods placed near hazards, spikes, or bad footing
- useful for pre-clearing a route before a time mission

Stage use:
- `Hive Shaft`
- `Overgrown Foundry`
- `Queen's Core`

Design rule:
- should pressure routing, not just occupy space
- sacs and core need crisp readable weak zones

### 5. `Rail Sentinel`

Role:
- fixed turret or rail node that locks a lane and punishes blind jumps

Why blade is good:
- once closed on, it should die fast to a single committed strike
- dive or dash cut is the stylish answer

Why gun is good:
- blaster can break shutters, exposed emitters, or side nodes before the final close
- gives the player a smart ranged setup tool without making melee irrelevant

Stage use:
- `Royal Armory`
- `Flooded Transit`

Design rule:
- strong line-of-fire telegraph
- high threat until solved
- fragile once the player gets in

### 6. `Pulse Mine`

Role:
- floating pressure orb that denies a ledge, choke, or recovery line

Why blade is good:
- a committed cut should briefly safe it, then pop it cleanly if the player times the entry
- melee answer is the stylish “cut the trap out of the lane” option

Why gun is good:
- blaster can detonate it early from a safe angle
- the best option when the mine is covering a bad landing or stacked near other hazards

Stage use:
- `Hive Shaft`
- `Flooded Transit`
- `Royal Armory`

Design rule:
- should threaten route timing, not just punish curiosity
- blast radius must be legible before detonation
- safe melee timing must be generous enough to learn

### 7. `Warder Husk`

Role:
- elite armored champion that anchors a mission room or sub-route

Why blade is good:
- after armor breaks, melee should be the fastest and coolest punish route
- should support bounce/rebound finishers or dash-string conversions

Why gun is good:
- blaster strips distant armor nodes, floating sigils, or shoulder weak points
- lets the player stage the fight instead of face-tanking the opener

Stage use:
- `Royal Armory`
- `Queen's Core`

Design rule:
- heavy anticipation
- clear state changes
- never a sponge with no rhythm break

## Enemy Mix Rules

- At least one enemy in a room should reward `Arc Cutter`.
- At least one enemy in a room should justify opening with `Blaster`.
- Do not let any common enemy be fully invalidated by one mode forever.
- If the gun answer is safer, the blade answer should be more rewarding.
- If the blade answer is faster, the gun answer should still be dependable.

## Mission Pressure Patterns

### Route Pressure

- `Mite Drifter` + `Brood Pod`
- the gun opens the lane, the blade cashes out the cluster

### Duel Pressure

- `Lancer Wasp`
- melee interception is the cool answer, gun stagger is the stabilizer

### Space-Control Pressure

- `Rail Sentinel` + `Shellback Crawler`
- gun removes the ranged lock, blade converts the opening into movement

### Anchor Pressure

- `Warder Husk` with smaller support bugs
- gun strips or interrupts, blade closes the fight

## First Slice Recommendation

Build these four first:

1. `Mite Drifter`
2. `Shellback Crawler`
3. `Brood Pod`
4. `Lancer Wasp`

That gives the first vertical slice:

- one fragile air target
- one armored ground target
- one route-control nest
- one aggressive duelist

That is enough to prove the blade/gun swap without bloating production.

## Failure Modes

- If common enemies are easier with gun in every case, the game slides back into ranged safety.
- If every enemy demands melee, the swap option becomes cosmetic.
- If blade kills do not give more momentum than gun kills, the risk/reward loop dies.
- If enemy bodies are noisy or weak zones are unclear, both weapons feel worse.

## Approval Bar

Ship an enemy only if:

- the hurt zone is readable at gameplay scale
- there is a clear reason to use blade
- there is a clear reason to use gun
- the death effect is satisfying in under 0.25 seconds
- the enemy improves route decisions instead of just taxing HP
