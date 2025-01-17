Class {
	#name : 'CodeTransformationMerger',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

{ #category : 'internals' }
CodeTransformationMerger >> applyChange: change toOld: oldString [

	^ oldString copyReplaceFrom: change start to: change start + change length with: change change
]

{ #category : 'internals' }
CodeTransformationMerger >> applyChanges: changes toOld: old [

	| result changeSize |
	result := old.
	changeSize := 0.
	changes sort: [ :a :b | a start < b start ].
	changes do: [ :change |
		| diffStart diffEnd diffValue |
		diffStart := change start + changeSize.
		diffEnd := diffStart + change length.
		diffValue := change change.
		result := result copyReplaceFrom: diffStart to: diffEnd with: diffValue.
		changeSize := changeSize + diffValue size - change length - 1 ].
	^ result
]

{ #category : 'internals' }
CodeTransformationMerger >> calculateDiffFromNew: new toOld: old [

	| cold cnew i last_space old_len new_len |
	cold := nil.
	cnew := nil.
	i := 0.
	last_space := 0.
	[ i < old size and: [ cold = cnew ] ] whileTrue: [
		i := i + 1.
		cold := old at: i.
		cnew := new at: i.
		cold = Character space ifTrue: [
			last_space := i.
			self assert: cnew = Character space ] ].
	old_len := old indexOf: Character space startingAt: last_space + 1 ifAbsent: [ old size + 1 ].
	new_len := new indexOf: Character space startingAt: last_space + 1 ifAbsent: [ new size + 1 ].
	old_len := old_len - 1.
	new_len := new_len - 1 "Strip space".
	^ StringChangeDiff start: i length: old_len - i change: (new copyFrom: i to: new_len)
]

{ #category : 'api' }
CodeTransformationMerger >> mergeCodeTransformations: transformedMethodsSourceCode in: targetString [

	| diffs |
	diffs := transformedMethodsSourceCode collect: [ :aSourceCode | self calculateDiffFromNew: aSourceCode toOld: targetString ].
	^ self applyChanges: diffs toOld: targetString
]
