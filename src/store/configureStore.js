import { createStore, applyMiddleware, compose } from 'redux'
import { createLogger } from 'redux-logger'
import rootReducer from './reducers'

// this is just one way to configure a redux store - this allows us to see in the console whenever an action is triggered

const loggerMiddleware = createLogger()
const middleware = []

// For redux devTools
const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose // allows us to connect devTools to our app

export default function configureStore(preloadedState) { 
	return createStore(
		rootReducer,
		preloadedState,
		composeEnhancers(applyMiddleware(...middleware, loggerMiddleware))
	)
}