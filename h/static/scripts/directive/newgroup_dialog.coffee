###*
# @ngdoc directive
# @name newgroup Dialog
# @restrict A
# @description The dialog that leads to the creation of a new group.
###
module.exports = ['$timeout', '$rootScope', 'localStorage', ($timeout, $rootScope, localStorage) ->
    link: (scope, elem, attrs, ctrl) ->
        scope.$watch (-> scope.groupDialog.visible), (visible) ->
            if visible
                $timeout (-> elem.find('#nameGroup').focus().select()), 0, false

        scope.$watch (-> scope.showLink), (visible) ->
            if visible
                $timeout (-> elem.find('#copyLink').focus().select()), 0, false

        scope.groupName = "groupName"
        scope.showLink = false

        scope.newgroup = ->
            $rootScope.socialview.selected = false
            for view in $rootScope.views
                if view.name == $rootScope.socialview.name
                    view.selected = false
            $rootScope.views.push({name:scope.groupName, icon:'h-icon-group', selected:true})
            if localStorage.getItem 'group1.name'
                localStorage.setItem 'group2.name', scope.groupName
                localStorage.setItem 'group2.icon', 'h-icon-group'
            else if localStorage.getItem 'group2.name'
                localStorage.setItem 'group3.name', scope.groupName
                localStorage.setItem 'group3.icon', 'h-icon-group'
            else
                localStorage.setItem 'group1.name', scope.groupName
                localStorage.setItem 'group1.icon', 'h-icon-group'
            $rootScope.socialview = {name:scope.groupName, icon:'h-icon-group', selected:true}
            scope.showLink = true
            scope.groupLink = "https://hypothes.is/g/102498/" + scope.groupName

    controller: 'AppController'
    templateUrl: 'newgroup_dialog.html'
]
