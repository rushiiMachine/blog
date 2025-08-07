---
title: 'Modding apps on Android'
description: 'A brief overview of various ways of hooking functions on Android'
#image:
published: 2024-06-21
draft: true
tags: [ "Android", "Modding", "Hooking" ]
---

There's a lot of reasons one would want to mod an app: removing ads, removing annoying functionality, adding custom functionality,
fixing bugs in abandoned apps, cheating in games, and much, much more. It's not my place to judge people what they do with their own
device, as I have a lot of modded apps myself - nearly everything I use on the daily is modded.

But *how* this is achived is pretty mysterious to everyone who is not actually themselves modding apps. My goal with this post is
to cover all the ways *I* know about to mod Android apps, and specifically on how to hook functions inside apps.

# Xposed

Going back to over a decade ago, one of the most popular tools for modding android apps is the usage of xposed-like frameworks (ex:
[the original Xposed], [EdXposed], [LSPosed]) that are injected into the system to modify the behavior of any installed app.
These tools are loaded into the system itself through the use of rooting (such as via [Magisk]), which requires an unlocked
bootloader. While the very first Xposed framework required building patched Android from source code, modern Xposed frameworks
such as [LSPosed] can be loaded as a [Magisk] module, which itself is a root framework that patches boot images to gain root.

Once loaded, Xposed frameworks inject into the app process, load a hooking library such as [#LSPlant], and then run all
the user's installed Xposed modules to hook functions in the target app and modify their behavior. More details about this
can be found under the [#LSPlant] section. The best part about this is that the target app does not have to be reinstalled
with the patches, as they are applied from the system at runtime! This methods

However, the main drawback of this approach is that this requires root on the device - requiring an unlockable bootloader - which
nowadays is becoming more and more rare with the erosion of consumer control by OEMs. (Don't buy carrier phones, Samsung,
Huawei, and *many* other brands!) This makes Xposed and rooting completely out of reach for most people, which to me is very sad.
However, rooting your device has some significant potential consequences, such as, voiding your warranty, signifcantly lowering the
security of your device, making some apps unusable without specialized fixes (such as for banking oftentimes), and lowering your
system Play Integrity level if you don't put in extra work. But there's a silver lining to all of this; there's still other ways to
patch apps, without requiring root, that have much less drawbacks!

<!-- The Xposed framework can then patch the Dalvik/ART VM (which runs the source code, as compiled DEX bytecode) in order to find individual native representations of methods and replace the underlying instructions/redirect it to another method, effectively setting a hook in the target app and allowing the modder to change functionality without ever modifying the underlying app. Since these patches are run via the Zygote hook, any integrity checks the app may perform on itself to detect changes will pass (assuming the root environment is sufficient hidden, which has become a cat-and-mouse game between modders and large app developers). -->

# LSPlant

These exact same patches on the VM can be run without needing to inject the Zygote process.

Since all apps are sandboxed under one user, everything is accessible; the VM, bytecode, and native libs are even loaded under the same
process! Anything can be modified at runtime, including the Android Runtime (ART) itself! ART handles executing bytecode, which is what
allows apps to even run. By hooking into and modifying the internals of the loaded VM (internally called `libart`) it's possible to achive
modifying the app's functionality at runtime.

This is significantly made easier given that Android does not have `W^X` page protection (pages can only be writable OR executable) and
code page signing (unlike iOS, where you can't create a `RWX` page unless you have the JIT entitlement, which is inaccessible without
a debugger attached, or a Jailbreak). Using this freedom, it's possible to freely change the behavior of the VM itself, and all of the
bytecode it runs!

# Smali Patching


<!-- @formatter:off -->

[the original Xposed]: https://github.com/rovo89/Xposed
[EdXposed]: https://github.com/ElderDrivers/EdXposed
[LSPosed]: https://github.com/LSPosed/LSPosed

[Magisk]: https://github.com/topjohnwu/Magisk