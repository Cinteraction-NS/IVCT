# Licensing for plugin authors

<!--
SPDX-License-Identifier: MIT
SPDX-FileCopyrightText: 2026 Cinteraction d.o.o. and the IVCT contributors
-->

This note explains the licensing posture of plugins written for the
Intelligent Video Conferencing Toolkit (IVCT). It is intended for
plugin authors and for the legal teams who advise them. It is *not*
legal advice; if a specific deployment scenario is unclear, please
consult a lawyer who is familiar with open-source licensing.

## Short version

**You can license your plugin under any license you choose,
including a proprietary license.** Plugins are independent works,
not derivative works of the IVCT framework, because the plugin
interface is a documented inter-process REST contract rather than a
linking interface.

## Why this is the case

IVCT's framework is licensed under GPL-3.0-only. Section 5 of
GPL-3.0 ("Conveying Modified Source Versions") imposes obligations
on works that are "based on the Program" — that is, derivative works
in the copyright sense.

Two conditions of the plugin interface support the conclusion that
plugins running through that interface are not derivative works of
the framework:

1. **No linkage at the source or binary level.** A plugin does not
   `#include` any framework header, does not link against any
   framework library, does not call any framework function in
   process, and does not embed any framework code at build time.
   The plugin is built independently, packaged in its own container,
   and deployed independently.

2. **A documented inter-process contract.** A plugin communicates
   with the framework only via HTTP requests and responses described
   in the public plugin API documentation (see
   [`docs/plugin-author/api.md`](api.md) and the OpenAPI
   specification in [`docs/plugin-author/openapi.yaml`](openapi.yaml)).
   The protocol is the same kind of network boundary that GPL-3.0
   does not treat as creating a derivative work — equivalent in
   structure to a plugin invoking a separate web service over the
   public internet.

The Free Software Foundation has long maintained that inter-process
communication over a defined protocol does not, in itself, create a
derivative work. The Janus gateway on which IVCT builds operates
the same model: Janus is GPL-3.0, but Janus plugins (which are
shared objects linked at runtime) and Janus client applications
(which talk to Janus over a network) are routinely shipped under
many different licenses.

## What this means in practice

You may, without any obligation to release source code under
GPL-3.0:

- Write a plugin in any programming language.
- Build the plugin against any libraries you choose, including
  proprietary libraries.
- Bundle the plugin with proprietary model weights, training data,
  pre-processing, or post-processing code.
- Distribute the plugin under MIT, Apache-2.0, BSD, a proprietary
  license, or any other license you select.
- Sell or rent access to a hosted instance of your plugin.

The only requirement is that your plugin actually respects the
plugin contract — it must communicate with the framework solely
over the documented HTTP API, and must not embed framework code or
link against framework binaries.

## What would change this picture

Two patterns *could* potentially create a derivative work of the
framework, and plugin authors who want to retain full freedom over
their license should avoid both:

- **Embedding framework code.** Copying framework source files
  (even small fragments) into a plugin codebase makes the plugin a
  derivative work of the framework. If you find yourself wanting to
  reuse framework code, open an issue: we will probably be willing
  to relicense the relevant fragment under a permissive license, or
  to factor it into a library that can be consumed under more
  flexible terms.

- **Linking against framework libraries.** If we publish a
  library-style component of the framework that plugins could link
  against in process (for example, a future helper SDK), linking
  against that component would generally make the plugin a
  derivative work. We do not currently ship such a component, but
  if and when we do, it will carry a clear notice about its
  licensing implications.

## Commercial deployment of your plugin

If you intend to deploy your plugin in production alongside a
modified version of the IVCT framework, GPL-3.0 obligations attach
to your modifications of the framework, not to your plugin. You
have three options:

1. Run an unmodified copy of the framework. Your plugin runs
   alongside it; no source release of either the framework or the
   plugin is required.

2. Modify the framework and release your framework modifications
   under GPL-3.0. Your plugin remains under whatever license you
   chose.

3. Take an alternative commercial license for the framework from
   Cinteraction. Your framework modifications can then be kept
   private. Contact `[licensing@cinteraction.com]` to discuss.

## If in doubt

Open an issue describing your situation. We would much rather
answer a question early than discover after the fact that a plugin
author has been deterred by uncertainty about the legal posture.
