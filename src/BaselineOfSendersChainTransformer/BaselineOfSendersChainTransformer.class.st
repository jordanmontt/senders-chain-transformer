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
		spec package: 'SendersChainTransformer-Tests' with: [ spec requires: #( 'SendersChainTransformer' ) ].

		"External dependencies"
		spec baseline: 'MethodProxies' with: [ spec repository: 'github://pharo-contributions/MethodProxies' ].
		spec package: 'SendersChainTransformer-Tests' with: [ spec requires: #( 'MethodProxies' ) ].

		"Groups"
		spec group: 'default' with: #( 'core' 'tests' ).
		spec group: 'core' with: #( 'SendersChainTransformer' ).
		spec group: 'tests' with: #( 'SendersChainTransformer-Tests' ) ]
]
