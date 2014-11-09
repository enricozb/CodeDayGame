public enum GBECTS {
    SPIKES, PLATFORM
    float maxDistX, maxDistY, sX, sY;
    long period;//well, not very, I mean not even 24 hours really
    

    GBECTS(float x, float y, float maxX, float maxY, long period) {
        this.maxX = maxX;
        this.maxY = maxY;
        this.period = period;
    }
    
    get(float x, float y) {
        return Moving(x, x + maxDistX, y, y + maxDistY);
    }
    
    maxX(float x) {
        return x + maxDistX;
    }
    maxY(float y) {
        return y + maxDistY;
    }
}