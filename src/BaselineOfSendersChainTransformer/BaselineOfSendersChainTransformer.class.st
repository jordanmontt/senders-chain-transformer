Class {
	#name : 'BaselineOfSendersChainTransformer',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfSendersChainTransformer',
	#package : 'BaselineOfSendersChainTransformer'
}

{ #category : 'baselines' }
BaselineOfSendersChainTransformer >> baseline: spec [

	<baseline>
	spec for: #common do: [
		"Packages"
		spec package: 'SendersChainTransformer'.
		spec package: 'SendersChainTransformer-TestUtilities'.
		spec package: 'SendersChainTransformer-Tests'
			with: [ spec requires: #( 'SendersChainTransformer'  'SendersChainTransformer-TestUtilities') ].

		"External dependencies"
		spec baseline: 'MethodProxies' with: [ spec repository: 'github://pharo-contributions/MethodProxies' ].
		spec baseline: 'IllimaniProfiler' with: [ spec repository: 'github://jordanmontt/illimani-memory-profiler:dev' ].
		"Linking external dependencies"
		spec package: 'SendersChainTransformer-Tests' with: [ spec requires: #( 'MethodProxies' 'IllimaniProfiler') ].

		"Groups"
		spec group: 'default' with: #( 'core' 'tests' ).
		spec group: 'core' with: #( 'SendersChainTransformer' ).
		spec group: 'tests' with: #( 'SendersChainTransformer-Tests' ) ]
]
