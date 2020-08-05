# -*- coding: utf-8 -*-

"""Tests for default options."""
import os

from cookiecutter.main import cookiecutter


def test_defaults(monkeypatch, tmpdir):
    """Verify the operator call works successfully."""
    monkeypatch.chdir(os.path.abspath(os.path.dirname(__file__)))

    existing_context = {'region': 'us-east-1'}
    output = cookiecutter(
        '.', context_file='../nuki.yaml', existing_context=existing_context, no_input=True, output_dir=str(tmpdir)
    )
    assert len(output['aws_available_instances_']) > 1
