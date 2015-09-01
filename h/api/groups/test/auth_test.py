# -*- coding: utf-8 -*-
import mock

from h.api.groups import auth


def _mock_group(hashid):
    return mock.Mock(hashid=mock.Mock(return_value=hashid))


def test_set_permissions_does_not_modify_private_annotations():
    original_annotation = {
        'user': 'acct:jack@hypothes.is',
        'group': 'xyzabc',
        'permissions': {
            'read': ['acct:jack@hypothes.is']
        }
    }
    annotation_to_be_modified = original_annotation.copy()


    auth.set_permissions(annotation_to_be_modified)

    assert annotation_to_be_modified == original_annotation


def test_set_permissions_does_not_modify_non_group_annotations():
    for group in ('missing', None, '', '__world__'):
        original_annotation = {
            'user': 'acct:jack@hypothes.is',
            'permissions': {
                'read': ['acct:jack@hypothes.is']
            }
        }
        if group != 'missing':
            original_annotation['group'] = group
        annotation_to_be_modified = original_annotation.copy()

        auth.set_permissions(annotation_to_be_modified)

        assert annotation_to_be_modified == original_annotation


def test_set_permissions_sets_read_permissions_for_group_annotations():
    annotation = {
        'user': 'acct:jack@hypothes.is',
        'group': 'xyzabc',
        'permissions': {
            'read': ['group:__world__']
        }
    }

    auth.set_permissions(annotation)

    assert annotation['permissions']['read'] == ['group:xyzabc']


def test_group_principals_with_no_groups():
    user = mock.Mock(groups=[])

    assert auth.group_principals(user, mock.Mock()) == ['group:__world__']


def test_group_principals_with_one_group():
    user = mock.Mock(groups=[_mock_group('hashid1')])

    assert auth.group_principals(user, mock.Mock()) == [
        'group:__world__', 'group:hashid1']


def test_group_principals_with_three_groups():
    user = mock.Mock(groups=[
        _mock_group('hashid1'),
        _mock_group('hashid2'),
        _mock_group('hashid3'),
    ])

    assert auth.group_principals(user, mock.Mock()) == [
        'group:__world__', 'group:hashid1', 'group:hashid2', 'group:hashid3']
