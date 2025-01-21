Class {
	#name : 'CodeTransformationMerger',
	#superclass : 'Object',
	#category : 'SendersChainTransformer-Core',
	#package : 'SendersChainTransformer',
	#tag : 'Core'
}

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
CodeTransformationMerger >> isThereMethodRepetitionsBetween: anArrayOfCompiledMethods and: anotherArrayOfCompiledMethods [

	^ (anArrayOfCompiledMethods collect: #name as: Set) size ~= anotherArrayOfCompiledMethods size
]

{ #category : 'internals' }
CodeTransformationMerger >> mergeCodeTransformations: transformedMethodsSourceCode in: targetString [

	| diffs |
	diffs := transformedMethodsSourceCode collect: [ :aSourceCode | self calculateDiffFromNew: aSourceCode toOld: targetString ].
	^ self applyChanges: diffs toOld: targetString
]

{ #category : 'api' }
CodeTransformationMerger >> mergeCompiledMethods: transformedSenders [
	"If there are no repetitions, there is no merging so the same collection gets returned"

	| repetitions |	
	repetitions := Dictionary new.
	transformedSenders do: [ :aCompiledMethod |
		repetitions
			at: aCompiledMethod name
			ifPresent: [ :col | col add: aCompiledMethod ]
			ifAbsentPut: [ OrderedCollection with: aCompiledMethod  ] ].
	
	(repetitions select: [ :col | col size > 1 ]) keysAndValuesDo: [ :methodName :collection |
		"Merge the modifications on the same method"
		| originalSourceCode mergedCode mergedCompiledMethod |
		originalSourceCode := (OpalCompiler new source: methodName; evaluate) parseTree formattedCode 
		"As the merger manipulates strings, we need to make sure that the source code has the same structure.
		That's why we ask the formatted code".
		mergedCode := self
							mergeCodeTransformations: (collection collect: [ :m | m parseTree formattedCode ])
							in: originalSourceCode.
		mergedCompiledMethod := (OpalCompiler new compile: mergedCode)
			classBinding: collection anyOne methodClass;
			yourself.
		"Put the merged method"
		repetitions at: methodName put: { mergedCompiledMethod } ].

	^ repetitions values flattened.
]

{ #category : 'api' }
CodeTransformationMerger >> newMergeCompiledMethods: aListOfMethodsWithOffset [

	| first |
	first := aListOfMethodsWithOffset first.
	first method: (self ).
	aListOfMethodsWithOffset do: [ :aMetodWithOffset |
		(aMetodWithOffset method sourceNodeForPC: aMetodWithOffset offset) isMessage
			ifTrue: [ aMetodWithOffset method sourceNodeForPC: aMetodWithOffset offset ]
			ifFalse: [
				(aMetodWithOffset method literals select: #isCompiledBlock) detect: [ :block |
					(block sourceNodeForPC: 55) isMessage ] ] ]
]
