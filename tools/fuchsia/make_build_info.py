#!/usr/bin/env python
#
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
''' Interpolates build environment information into a file.
'''

from argparse import ArgumentParser
from datetime import datetime
from os import path
import subprocess
import sys
import json


def GetBuildTimestamp():
    return datetime.now().strftime('%Y-%m-%d %H:%M')


def GetDartSdkGitRevision(buildroot):
    project_root = path.join(buildroot, 'third_party', 'dart')
    return subprocess.check_output(
        ['git', '-C', project_root, 'rev-parse', 'HEAD']).strip()


def GetDartSdkSemanticVersion(buildroot):
    project_root = path.join(buildroot, 'third_party', 'dart')
    return subprocess.check_output(
        ['git', '-C', project_root, 'describe', '--abbrev=0']).strip()


def GetFlutterEngineGitRevision(buildroot):
    project_root = path.join(buildroot, 'flutter')
    return subprocess.check_output(
        ['git', '-C', project_root, 'rev-parse', 'HEAD']).strip()


def GetFuchsiaSdkVersion(buildroot):
    with open(path.join(
        buildroot,
        'fuchsia',
        'sdk',
        'linux',
        'meta',
        'manifest.json'),
    'r') as fuchsia_sdk_manifest:
        return json.load(fuchsia_sdk_manifest)['id']


def main():
    # Parse arguments.
    parser = ArgumentParser()
    parser.add_argument(
        '--input', action='store', help='input file path', required=True)
    parser.add_argument(
        '--output', action='store', help='output file path', required=True)
    parser.add_argument(
        '--buildroot',
        action='store',
        help='path to the flutter engine buildroot',
        required=True)
    args = parser.parse_args()

    # Read, interpolate, write.
    with open(args.input, 'r') as i, open(args.output, 'w') as o:
        o.write(
            i.read()
            .replace('{{BUILD_TIMESTAMP}}', GetBuildTimestamp())
            .replace(
                '{{DART_SDK_GIT_REVISION}}',
                GetDartSdkGitRevision(args.buildroot))
            .replace(
                '{{DART_SDK_SEMANTIC_VERSION}}',
                GetDartSdkSemanticVersion(args.buildroot))
            .replace(
                '{{FLUTTER_ENGINE_GIT_REVISION}}',
                GetFlutterEngineGitRevision(args.buildroot))
            .replace(
                '{{FUCHSIA_SDK_VERSION}}',
                GetFuchsiaSdkVersion(args.buildroot)))


if __name__ == '__main__':
    main()
