#pragma once

struct number{
    long int integer;
    float rational;
    int is_rational;
    int modulo_error;
};



static struct number addition(struct number a, struct number b)
{
    struct number to_return = {0,0,0};

    if(!a.is_rational && !b.is_rational)
    {
        to_return = (struct number){a.integer+b.integer,0,0};
    }else{
        if(!(a.is_rational && b.is_rational))
        {
            to_return= (struct number){0,a.integer+b.integer+a.rational+b.rational,1};
        }else{
            to_return= (struct number){0,a.rational+b.rational,1};
        }
    }

    return to_return;
}

static struct number substraction(struct number a, struct number b)
{
    struct number to_return = {0,0,0};

    if(!a.is_rational && !b.is_rational)
    {
        to_return = (struct number){a.integer-b.integer,0,0};
    }else{
        if(!(a.is_rational && b.is_rational))
        {
            to_return= (struct number){0,a.integer-b.integer-a.rational-b.rational,1};
        }else{
            to_return= (struct number){0,a.rational-b.rational,1};
        }
    }

    return to_return;
}

static struct number multiply(struct number a, struct number b)
{
    struct number to_return = {0,0,0};

    if(!a.is_rational && !b.is_rational)
    {
        to_return = (struct number){a.integer*b.integer,0,0};
    }else{
        if(a.is_rational && !b.is_rational)
        {
            to_return = (struct number){0,a.rational*b.integer,1};
        }else{
            if(b.is_rational && !a.is_rational)
            {
                to_return = (struct number){0,b.rational*a.integer,1};
            }else{
                to_return = (struct number){0,b.rational*a.rational,1};
            }
        }
    }

    return to_return;
}

static struct number division(struct number a, struct number b)
{
    struct number to_return = {0,0,0};

    if(!a.is_rational && !b.is_rational)
    {
        to_return = (struct number){a.integer/b.integer,0,0};
    }else{
        if(a.is_rational && !b.is_rational)
        {
            to_return = (struct number){0,(float)((float)(a.rational)/(float)(b.integer)),1};
        }else{
            if(b.is_rational && !a.is_rational)
            {
                to_return = (struct number){0,(float)((float)(a.rational)/(float)(b.integer)),1};
            }else{
                to_return = (struct number){0,(float)((float)(a.rational)/(float)(b.rational)),1};
            }
        }
    }

    return to_return;
}

static struct number modulo(struct number a, struct number b)
{
    struct number to_return = {0,0,0};

    if(!a.is_rational && !b.is_rational)
    {
        to_return = (struct number){a.integer%b.integer,0,0};
    }else{
       to_return = (struct number){0,0,0,1};
    }

    return to_return;
}

static struct number negate(struct number a)
{
    if(!a.is_rational)
    {
        a=(struct number){0,-a.rational,1};
    }else{
        a=(struct number){-a.integer,0,0};
    }
    return a;
}