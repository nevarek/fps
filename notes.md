# FPS
using godot version `4.0.dev.custom_build.2a702cff4`

# What this won't cover
- Standard Godot syntax, you can use a search engine and documentation to cover this. Syntax will be covered if, for some reason, it is unusual.
- Updates to syntax. If syntax is changed through an update, do not depend on this reference to contain the correct/updated syntax. Most of the time, it will be fairly easy to tell what the task is trying to accomplish. Once you understand this, you can work to implement it in the newer syntax. For everything else, you can message me to update this reference and hope that I can.
- Installing Godot, this can be found in documentation. I am using a build of the specific commit listed on the top of this document. Installing this specific Git SHA will most likely **not be necessary**, but using the same major (and perhaps minor) version will be a good idea.
- Fundamentals of coding included but not limited to: data types, data structures, loops, flow control, functions, call stacks, and programming paradigms. If any/all of these sound unfamiliar to you, I suggest you look them up to become more familiar with them or at least know they exist.
- The "Right Way To Do Things", if I implement something incorrectly or in a bad way, I am comfortable enough for you to let me know. Just don't expect too much from this reference. Definitely do not harass me or other users of this reference. If you can't control yourself and be nice, I probably won't bother responding to your feedback.
- Various 3D modelling stuff. Knowing what these are will be helpful because I might just skip over them: mesh, material, rigging, animations, UV mapping, and Godot-supported 3D file formats. For example, if your model doesn't import correctly or stuff is missing, this reference is not a proper place to seek remedies. What's even more likely is that I may not even be able to help you.

# Intended Audience
- People who are comfortable with **autodidactic learning**, which is more commonly referred to self-education. Users of this reference should be aware that it will not always (and cannot) be updated to cover everything. Readers are expected to recognize when they need to stop and look up how to do something. Search engines are a good place to start. Having this as a habit will be invaluable, no matter what you're doing.

- Readers **familiar with at least one game engine** or at least the architecture of a theoretical one. It doesn't have to be Godot. Having familiarity with Godot will of course be useful. Unity has its own architecture, and other engines are specialized for a specific purpose. Godot has documentation on its architecture to reference if the need ever comes up. In addition, Godot is not going to have bells and whistles other engines may have, and you may be stuck with implementing things yourself.

- If you've **made a few projects yourself in Godot**, this will be ideal. Even if it is a 2D project and unpublished, that is something you can bring to the table. Do not invalidate your experience because it doesn't match perfectly to 3D or if it was never finished or published. Ideally you'd probably have a graveyard of dead projects you've already did some learning from, and are looking to get into 3D (at least starting with an FPS).

- Readers that have **done the FPS tutorial found in the Godot documentation** and/or the other 3D tutorials. You don't have to memorize every thing about it. If you've gone through it, you will be ahead in most places, and will already be ready to explore outside the box.

# General Outline
- the world
- the 3D node
- the camera
- displaying an object
- rotating an object
- moving an object
- there are layers by the way
- you can have multiple cameras
- fps skeleton
- where to start with sizing everything
- introducing the physics engine
- UI and interaction with static objects
- our first weapons
    - melee
    - ranged
- destructible objects?

## 3D: The world, the node, and how to describe them in space

The 3D world in Godot is made up of 3 axes. X, Y, and Z. Unsurprising. In Godot 2D, X is horizontal, and Y is vertical. In 3D this is expanded with X and Z being the "horizontal" and Y being "vertical".

Everything works as you'd expect. But if you think about it, there are a few permutations the orientation can be set up. By default in Godot, negative Z (`-Z`) is the "forward" direction, and positive Y (`+Y`) is "up". This means that moving left and right will use (`-X`) and (`+X`) respectively. **Don't worry if this doesn't make too much sense right now.** When we start moving and rotating objects, this will become important to understand and much easier to visualize.

The 3D nodes in Godot are called `Node3D`. This name has changed from version 3 of Godot if you've used it before (formerly `Spatial`). Let's inspect what makes up a `Node3D`, as every 3D object will have the same properties and methods, even particles.

`Node3D` is a descendant of `Node`, so it has all the handy features a `Node` would have. It has many properties and methods but we'll cover a few in detail by experimenting with them. The `position`, the `rotation`, and the `basis` properties are going to be the foundation for describing this object in space. Things like the `transform` are other ways to represent the same object.

There are two ways to observe the object in space, one is a local interpretation, and the other is a global interpretation. The global is easy to understand, it's the object's absolute position in space. Imagine yourself pointing to Earth's exact spot in the galaxy. At some point, we have to represent the game world within the computer, and global space is where everything in your game will fit into.

For me, local space is best imagined with an object on a table. Ignore gravity and inertia for now, we aren't applying forces to the objects here. An object can be in the middle of the table, on the left, underneath it, on its side, etc., with the table always being considered as a starting point.

If you were to flip the table over (remember to ignore forces), imagine everything else on it moving along with it. You could imagine that the object is effectively "attached" to the table. And yes, if you were to flip global space over like the table, literally everything in your game would come along for the ride. The object's local coordinates are like an offset from the table's own coordinates.

Moving an object is often called a `translation`, and rotation is typically done in **radians**. There are functions to convert radians to degrees and vice versa. A translation in global space *can* be exactly the same as a local translation in space. It likely will not be the case once objects start rotating and translating every which way.

A common question will then occur: Which way is the object's forward direction? Often you want to move the object forward, or up. Oh god, are we gonna need math?

Luckily, not yet. An object's `basis` is exactly what you're looking for here. The solution is to translate along an object's -Z axis of the `basis` to go "forward". We will encounter this with our fps camera and be using the basis to resolve which way forward is after we start looking around.

Though, forward may be a different direction if your camera is set up differently from the defaults.

# The Camera

The camera is a window into the 3D world. For the purposes of this reference, the camera is mounted onto an parent object that has its own rotation and translation. We rarely want to translate the camera anywhere, but rotating it will be something we do.

If you were to mount the camera on backwards, then it would be facing in the `+Z` axis, making *that* the "forward" direction for this object. As said before, by default the camera is going to be facing the `-Z` direction.

We all secretly wish the camera could see forever, but it also has technical limitations to it. For a majority of the time, the camera will have something in front of it before it ever reaches the furthest point it can see (sometimes not!). If the camera can see an object, it will have to be rendered by the engine, which costs resources. Thankfully everything the camera doesn't see is handled by the game engine to live in memory. If stuff is in memory it doesn't have to engage any of the rendering pieces that cost resources.

The limits of the camera are dictated by (roughly) three values. `near` describes how close an object can get before it is considered too close to render, `far` is the opposite, and `fov` (field of view) is how wide of an angle the camera casts a net, horizontally. There are also **perspectives** on cameras that can modify things even further. For now, though, the defaults are what we want to use.

# Displaying an object

Every object we want to **see** needs to have a part that gets rendered by the engine. For 3D, the most common will be a `MeshInstance3D`.

Create a new scene (or start with the default one). Add a `MeshInstance3D` and a `Camera3D` to this scene. Use the inspector to add a mesh to `MeshInstance3D`. Pick the cube as it will be easier to see the next exercises. Next, we're going to pull back the camera so we can see the object. The easiest way to to do this is to set the camera's `Z` and `Y` positions to 6. Then, set the `X` rotation to `-45` degrees.
