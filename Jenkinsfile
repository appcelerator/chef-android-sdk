#! groovy

timestamps {
	node('chefdk && (osx || linux)') {
		def isPR = false

		stage('Checkout') {
			checkout scm

			isPR = env.BRANCH_NAME.startsWith('PR-')
		}

		ansiColor('xterm') {
			stage('Lint') {
				def foodcriticVersion = sh(returnStdout: true, script: 'foodcritic -V').trim()
				echo "foodcritic version: ${foodcriticVersion}"
				def cookstyleVersion = sh(returnStdout: true, script: 'cookstyle -V').trim()
				echo "cookstyle version: ${cookstyleVersion}"
				def berksVersion = sh(returnStdout: true, script: 'berks version').trim()
				echo "berks version: ${berksVersion}"
				def kitchenVersion = sh(returnStdout: true, script: 'kitchen -v').trim()
				echo "kitchen version: ${kitchenVersion}"

				ansiColor('xterm') {
					sh(returnStatus: true, script: 'foodcritic -f correctness -B site-cookbooks/')
					sh(returnStatus: true, script: 'cookstyle --fail-level E .') // Cookstyle wraps rubocop
				} // ansiColor
				warnings(
					consoleParsers: [[parserName: 'Foodcritic'], [parserName: 'Rubocop']],
					failedTotalAll: '0', // Fail if there are *any* warnings
					canComputeNew: false,
					canResolveRelativePaths: false,
					defaultEncoding: '',
					excludePattern: '',
					healthy: '',
					includePattern: '',
					messagesPattern: '',
					unHealthy: '')
				// This doesn't seem to "fail" the build immediately if there are warnings!
				if (currentBuild.resultIsWorseOrEqualTo('FAILURE')) {
					error 'Warnings detected'
					return
				}
			} // stage

			stage('Test') {
				sh 'berks install' // installs all the cookbooks to local cache, using Berksfile.lock
				try {
					sh 'kitchen test'
				}
				finally {
					junit '*_inspec.xml'
				}
			} // stage

			stage('Deploy') {
				if (!isPR) {
					// sh 'berks upload'
					// TODO Push the cookbook up to our chef server?
				}
			} // stage
		} // ansiColor
	} // node
} // timestamps
